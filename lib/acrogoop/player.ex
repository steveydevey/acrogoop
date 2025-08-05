defmodule Acrogoop.Player do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "players" do
    field :name, :string
    field :session_id, :string
    field :score, :integer, default: 0
    field :is_creator, :boolean, default: false

    belongs_to :game, Acrogoop.Game
    has_many :submissions, Acrogoop.Submission
    has_many :votes, Acrogoop.Vote

    timestamps(type: :utc_datetime)
  end

  def changeset(player, attrs) do
    player
    |> cast(attrs, [:name, :session_id, :score, :is_creator, :game_id])
    |> validate_required([:name, :session_id, :game_id])
    |> validate_length(:name, min: 1, max: 50)
    |> unique_constraint([:session_id, :game_id])
  end
end