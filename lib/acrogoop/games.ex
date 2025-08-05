defmodule Acrogoop.Games do
  @moduledoc """
  The Games context.
  """

  import Ecto.Query, warn: false
  alias Acrogoop.Repo
  alias Acrogoop.{Game, Player, Submission, Vote}

  @doc """
  Creates a game with the given creator name and options.
  """
  def create_game(creator_name, opts \\ %{}) do
    code = generate_unique_code()
    
    attrs = %{
      code: code,
      creator_name: creator_name,
      rounds_total: Map.get(opts, :rounds_total, 3),
      round_time_limit: Map.get(opts, :round_time_limit, 10),
      voting_time_limit: Map.get(opts, :voting_time_limit, 10)
    }

    %Game{}
    |> Game.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Creates a game and automatically adds the creator as a player.
  """
  def create_game_with_creator(creator_name, session_id, opts \\ %{}) do
    case create_game(creator_name, opts) do
      {:ok, game} ->
        case join_game(game.id, creator_name, session_id, true) do
          {:ok, _player} -> {:ok, game}
          {:error, reason} -> {:error, reason}
        end
      {:error, reason} -> {:error, reason}
    end
  end

  @doc """
  Gets a game by its code.
  """
  def get_game_by_code(code) do
    Repo.get_by(Game, code: code)
  end

  @doc """
  Gets a game by id with preloaded associations.
  """
  def get_game!(id) do
    Repo.get!(Game, id)
    |> Repo.preload([:players, :submissions, :votes])
  end

  @doc """
  Adds a player to a game.
  """
  def join_game(game_id, player_name, session_id, is_creator \\ false) do
    attrs = %{
      name: player_name,
      session_id: session_id,
      game_id: game_id,
      is_creator: is_creator
    }

    %Player{}
    |> Player.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Starts a game by generating letters and updating status.
  """
  def start_game(game_id) do
    game = Repo.get!(Game, game_id)
    letters = Game.generate_letters()

    game
    |> Game.changeset(%{status: :in_progress, current_letters: letters})
    |> Repo.update()
  end

  @doc """
  Submits a phrase for a player in the current round.
  """
  def submit_phrase(game_id, player_id, phrase) do
    game = Repo.get!(Game, game_id)
    
    attrs = %{
      phrase: phrase,
      round_number: game.current_round,
      submitted_at: DateTime.utc_now(),
      game_id: game_id,
      player_id: player_id
    }

    %Submission{}
    |> Submission.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Moves game to voting phase.
  """
  def start_voting(game_id) do
    game = Repo.get!(Game, game_id)

    game
    |> Game.changeset(%{status: :voting})
    |> Repo.update()
  end

  @doc """
  Casts a vote for a submission.
  """
  def vote_for_submission(game_id, voter_id, submission_id) do
    game = Repo.get!(Game, game_id)
    submission = Repo.get!(Submission, submission_id)

    # Prevent voting for own submission
    if submission.player_id == voter_id do
      {:error, :cannot_vote_for_own_submission}
    else
      attrs = %{
        round_number: game.current_round,
        game_id: game_id,
        player_id: voter_id,
        submission_id: submission_id
      }

      %Vote{}
      |> Vote.changeset(attrs)
      |> Repo.insert()
    end
  end

  @doc """
  Completes the current round, updates scores, and advances to next round or ends game.
  """
  def complete_round(game_id) do
    game = Repo.get!(Game, game_id) |> Repo.preload([:players, :submissions, :votes])
    
    # Calculate scores for this round
    vote_counts = 
      game.votes
      |> Enum.filter(&(&1.round_number == game.current_round))
      |> Enum.group_by(& &1.submission_id)
      |> Enum.map(fn {submission_id, votes} -> {submission_id, length(votes)} end)
      |> Map.new()

    # Update player scores
    current_submissions = 
      game.submissions
      |> Enum.filter(&(&1.round_number == game.current_round))

    Enum.each(current_submissions, fn submission ->
      vote_count = Map.get(vote_counts, submission.id, 0)
      if vote_count > 0 do
        player = Repo.get!(Player, submission.player_id)
        new_score = player.score + (vote_count * 100)
        
        player
        |> Player.changeset(%{score: new_score})
        |> Repo.update()
      end
    end)

    # Advance to next round or complete game
    if game.current_round < game.rounds_total do
      # Next round
      letters = Game.generate_letters()
      
      game
      |> Game.changeset(%{
        current_round: game.current_round + 1,
        current_letters: letters,
        status: :in_progress
      })
      |> Repo.update()
    else
      # Complete game
      game
      |> Game.changeset(%{status: :completed})
      |> Repo.update()
    end
  end

  @doc """
  Gets current round submissions for a game.
  """
  def get_current_submissions(game_id) do
    game = Repo.get!(Game, game_id)
    
    from(s in Submission,
      where: s.game_id == ^game_id and s.round_number == ^game.current_round,
      preload: [:player]
    )
    |> Repo.all()
  end

  @doc """
  Gets players for a game ordered by score.
  """
  def get_players_by_score(game_id) do
    from(p in Player,
      where: p.game_id == ^game_id,
      order_by: [desc: p.score, asc: p.inserted_at]
    )
    |> Repo.all()
  end

  @doc """
  Gets a player by game_id and session_id.
  """
  def get_player_by_session(game_id, session_id) do
    Repo.get_by(Player, game_id: game_id, session_id: session_id)
  end

  defp generate_unique_code do
    code = Game.generate_code()
    
    case get_game_by_code(code) do
      nil -> code
      _ -> generate_unique_code()
    end
  end
end