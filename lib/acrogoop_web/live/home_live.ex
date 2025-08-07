defmodule AcrogoopWeb.HomeLive do
  use AcrogoopWeb, :live_view
  alias Acrogoop.Games

  @impl true
  def mount(_params, session, socket) do
    session_id = session["session_id"] || generate_session_id()
    
    require Logger
    Logger.info("HomeLive Mount - Session ID: #{session_id}")
    
    {:ok,
     socket
     |> assign(:creator_name, "")
     |> assign(:game_code, "")
     |> assign(:rounds_total, 3)
     |> assign(:round_time_limit, 30)
     |> assign(:voting_time_limit, 120)
     |> assign(:session_id, session_id)}
  end

  @impl true
  def handle_event("create_game", %{"creator_name" => name, "rounds_total" => rounds, 
                                   "round_time_limit" => round_time, "voting_time_limit" => voting_time}, socket) do
    opts = %{
      rounds_total: String.to_integer(rounds),
      round_time_limit: String.to_integer(round_time),
      voting_time_limit: String.to_integer(voting_time)
    }

    require Logger
    Logger.info("Creating game with session ID: #{socket.assigns.session_id}")
    
    case Games.create_game_with_creator(name, socket.assigns.session_id, opts) do
      {:ok, game} ->
        Logger.info("Game created: #{game.code}, redirecting...")
        {:noreply, redirect(socket, to: "/game/#{game.code}?s=#{socket.assigns.session_id}")}

      {:error, _changeset} ->
        {:noreply,
         socket
         |> put_flash(:error, "Could not create game")}
    end
  end

  @impl true
  def handle_event("join_game", %{"game_code" => code}, socket) do
    case Games.get_game_by_code(String.upcase(code)) do
      nil ->
        {:noreply,
         socket
         |> put_flash(:error, "Game not found")}

      _game ->
        {:noreply, redirect(socket, to: "/game/#{String.upcase(code)}")}
    end
  end

  @impl true
  def handle_event("update_creator_name", %{"creator_name" => name}, socket) do
    {:noreply, assign(socket, :creator_name, name)}
  end

  @impl true
  def handle_event("update_game_code", %{"game_code" => code}, socket) do
    {:noreply, assign(socket, :game_code, code)}
  end

  @impl true
  def handle_event("update_rounds", %{"rounds_total" => rounds}, socket) do
    {:noreply, assign(socket, :rounds_total, String.to_integer(rounds))}
  end

  @impl true
  def handle_event("update_round_time", %{"round_time_limit" => time}, socket) do
    {:noreply, assign(socket, :round_time_limit, String.to_integer(time))}
  end

  @impl true
  def handle_event("update_voting_time", %{"voting_time_limit" => time}, socket) do
    {:noreply, assign(socket, :voting_time_limit, String.to_integer(time))}
  end

  defp generate_session_id do
    :crypto.strong_rand_bytes(16) |> Base.encode64()
  end
end