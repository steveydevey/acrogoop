defmodule AcrogoopWeb.GameLive do
  use AcrogoopWeb, :live_view
  alias Acrogoop.Games
  alias Phoenix.PubSub

  @impl true
  def mount(%{"code" => code} = params, session, socket) do
    if connected?(socket) do
      PubSub.subscribe(Acrogoop.PubSub, "game:#{code}")
    end

    # Use URL parameter if present, fallback to session, then generate new
    # URL decode the session parameter to handle + characters correctly
    url_session_id = if params["s"], do: String.replace(params["s"], " ", "+"), else: nil
    session_id = url_session_id || session["session_id"] || generate_session_id()
    
    require Logger
    Logger.info("GameLive Mount - Code: #{code}, Session ID: #{session_id}, URL param: #{params["s"]}")
    
    game = Games.get_game_by_code(code)

    case game do
      nil ->
        {:ok, 
         socket
         |> put_flash(:error, "Game not found")
         |> redirect(to: "/")}

      game ->
        {:ok,
         socket
         |> assign(:game, game)
         |> assign(:session_id, session_id)
         |> assign(:player, nil)
         |> assign(:submissions, [])
         |> assign(:players, [])
         |> assign(:time_remaining, 0)
         |> assign(:player_name, "")
         |> assign(:phrase_input, "")
         |> assign(:voting_for, nil)
         |> refresh_game_state()}
    end
  end

  @impl true
  def handle_event("join_game", %{"player_name" => name}, socket) do
    case Games.join_game(socket.assigns.game.id, name, socket.assigns.session_id) do
      {:ok, player} ->
        broadcast_update(socket.assigns.game.code)
        
        {:noreply,
         socket
         |> assign(:player, player)
         |> refresh_game_state()}

      {:error, _changeset} ->
        {:noreply,
         socket
         |> put_flash(:error, "Could not join game")}
    end
  end

  @impl true
  def handle_event("start_game", _, socket) do
    case Games.start_game(socket.assigns.game.id) do
      {:ok, _game} ->
        broadcast_update(socket.assigns.game.code)
        start_round_timer(socket.assigns.game.code, socket.assigns.game.round_time_limit)
        
        {:noreply, refresh_game_state(socket)}

      {:error, _changeset} ->
        {:noreply,
         socket
         |> put_flash(:error, "Could not start game")}
    end
  end

  @impl true
  def handle_event("submit_phrase", %{"phrase" => phrase}, socket) do
    case Games.submit_phrase(socket.assigns.game.id, socket.assigns.player.id, phrase) do
      {:ok, _submission} ->
        broadcast_update(socket.assigns.game.code)
        
        {:noreply,
         socket
         |> assign(:phrase_input, "")
         |> refresh_game_state()}

      {:error, _changeset} ->
        {:noreply,
         socket
         |> put_flash(:error, "Could not submit phrase")}
    end
  end

  @impl true
  def handle_event("vote", %{"submission_id" => submission_id}, socket) do
    case Games.vote_for_submission(socket.assigns.game.id, socket.assigns.player.id, submission_id) do
      {:ok, _vote} ->
        broadcast_update(socket.assigns.game.code)
        
        {:noreply, refresh_game_state(socket)}

      {:error, _} ->
        {:noreply,
         socket
         |> put_flash(:error, "Could not cast vote")}
    end
  end

  @impl true
  def handle_event("update_phrase", %{"phrase" => phrase}, socket) do
    {:noreply, assign(socket, :phrase_input, phrase)}
  end

  @impl true
  def handle_event("update_player_name", %{"player_name" => name}, socket) do
    {:noreply, assign(socket, :player_name, name)}
  end

  @impl true
  def handle_info({:game_updated, _code}, socket) do
    {:noreply, refresh_game_state(socket)}
  end

  @impl true
  def handle_info({:round_timer, time_remaining}, socket) do
    if time_remaining <= 0 do
      # Time's up - move to voting
      Games.start_voting(socket.assigns.game.id)
      broadcast_update(socket.assigns.game.code)
      start_voting_timer(socket.assigns.game.code, socket.assigns.game.voting_time_limit)
    end
    
    {:noreply, assign(socket, :time_remaining, time_remaining)}
  end

  @impl true
  def handle_info({:voting_timer, time_remaining}, socket) do
    if time_remaining <= 0 do
      # Voting time's up - complete round
      Games.complete_round(socket.assigns.game.id)
      broadcast_update(socket.assigns.game.code)
      
      # Start next round timer if game continues
      game = Games.get_game_by_code(socket.assigns.game.code)
      if game.status == :in_progress do
        start_round_timer(socket.assigns.game.code, game.round_time_limit)
      end
    end
    
    {:noreply, assign(socket, :time_remaining, time_remaining)}
  end

  defp refresh_game_state(socket) do
    game = Games.get_game_by_code(socket.assigns.game.code)
    submissions = Games.get_current_submissions(game.id)
    players = Games.get_players_by_score(game.id)
    
    require Logger
    Logger.info("Refresh game state - Session ID: #{socket.assigns.session_id}")
    Logger.info("Players in game: #{inspect(Enum.map(players, &{&1.name, &1.session_id}))}")
    
    # Find current player - check by session_id first, then by existing player id
    player = cond do
      socket.assigns.player && socket.assigns.player.id ->
        found = Enum.find(players, &(&1.id == socket.assigns.player.id))
        Logger.info("Found player by ID: #{inspect(found)}")
        found
      socket.assigns.session_id ->
        found = Games.get_player_by_session(game.id, socket.assigns.session_id)
        Logger.info("Found player by session: #{inspect(found)}")
        found
      true ->
        Logger.info("No player found")
        nil
    end

    socket
    |> assign(:game, game)
    |> assign(:player, player)
    |> assign(:submissions, submissions)
    |> assign(:players, players)
  end

  defp broadcast_update(game_code) do
    PubSub.broadcast(Acrogoop.PubSub, "game:#{game_code}", {:game_updated, game_code})
  end

  defp start_round_timer(game_code, seconds) do
    spawn(fn -> 
      Enum.each(seconds..0//-1, fn time ->
        PubSub.broadcast(Acrogoop.PubSub, "game:#{game_code}", {:round_timer, time})
        Process.sleep(1000)
      end)
    end)
  end

  defp start_voting_timer(game_code, seconds) do
    spawn(fn ->
      Enum.each(seconds..0//-1, fn time ->
        PubSub.broadcast(Acrogoop.PubSub, "game:#{game_code}", {:voting_timer, time})
        Process.sleep(1000)
      end)
    end)
  end

  defp generate_session_id do
    :crypto.strong_rand_bytes(16) |> Base.encode64()
  end

  defp can_start_game?(game, player, players) do
    game.status == :waiting && !is_nil(player) && player.is_creator && length(players) >= 3
  end

  defp player_has_submitted?(submissions, player_id) do
    Enum.any?(submissions, &(&1.player_id == player_id))
  end

end