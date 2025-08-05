defmodule Acrogoop.Game do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "games" do
    field :code, :string
    field :status, Ecto.Enum, values: [:waiting, :in_progress, :voting, :completed]
    field :rounds_total, :integer, default: 3
    field :round_time_limit, :integer, default: 10
    field :voting_time_limit, :integer, default: 10
    field :current_round, :integer, default: 1
    field :current_letters, :string
    field :creator_name, :string

    has_many :players, Acrogoop.Player
    has_many :submissions, Acrogoop.Submission
    has_many :votes, Acrogoop.Vote

    timestamps(type: :utc_datetime)
  end

  def changeset(game, attrs) do
    game
    |> cast(attrs, [:code, :status, :rounds_total, :round_time_limit, :voting_time_limit, 
                    :current_round, :current_letters, :creator_name])
    |> validate_required([:code, :creator_name])
    |> validate_inclusion(:rounds_total, 1..10)
    |> validate_inclusion(:round_time_limit, 5..60)
    |> validate_inclusion(:voting_time_limit, 5..30)
    |> unique_constraint(:code)
  end

  def generate_code do
    1..6
    |> Enum.map(fn _ -> Enum.random(?A..?Z) end)
    |> List.to_string()
  end

  def generate_letters(count \\ 6) do
    1..count
    |> Enum.map(fn _ -> Enum.random(?A..?Z) end)
    |> List.to_string()
  end
end