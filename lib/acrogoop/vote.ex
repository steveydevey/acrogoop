defmodule Acrogoop.Vote do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "votes" do
    field :round_number, :integer

    belongs_to :game, Acrogoop.Game
    belongs_to :player, Acrogoop.Player  # voter
    belongs_to :submission, Acrogoop.Submission

    timestamps(type: :utc_datetime)
  end

  def changeset(vote, attrs) do
    vote
    |> cast(attrs, [:round_number, :game_id, :player_id, :submission_id])
    |> validate_required([:round_number, :game_id, :player_id, :submission_id])
    |> unique_constraint([:game_id, :player_id, :round_number])
    |> validate_not_own_submission()
  end

  defp validate_not_own_submission(changeset) do
    case {get_field(changeset, :player_id), get_field(changeset, :submission_id)} do
      {player_id, submission_id} when is_binary(player_id) and is_binary(submission_id) ->
        # We'll check this constraint in the business logic layer
        changeset
      _ ->
        changeset
    end
  end
end