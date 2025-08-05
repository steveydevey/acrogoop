defmodule Acrogoop.Submission do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "submissions" do
    field :phrase, :string
    field :round_number, :integer
    field :submitted_at, :utc_datetime

    belongs_to :game, Acrogoop.Game
    belongs_to :player, Acrogoop.Player
    has_many :votes, Acrogoop.Vote

    timestamps(type: :utc_datetime)
  end

  def changeset(submission, attrs) do
    submission
    |> cast(attrs, [:phrase, :round_number, :submitted_at, :game_id, :player_id])
    |> validate_required([:phrase, :round_number, :game_id, :player_id])
    |> validate_length(:phrase, min: 1, max: 200)
    |> unique_constraint([:game_id, :player_id, :round_number])
  end
end