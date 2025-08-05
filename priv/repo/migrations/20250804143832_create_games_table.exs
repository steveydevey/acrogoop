defmodule Acrogoop.Repo.Migrations.CreateGamesTable do
  use Ecto.Migration

  def change do
    create table(:games, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :code, :string, null: false
      add :status, :string, null: false, default: "waiting"
      add :rounds_total, :integer, null: false, default: 3
      add :round_time_limit, :integer, null: false, default: 10
      add :voting_time_limit, :integer, null: false, default: 10
      add :current_round, :integer, null: false, default: 1
      add :current_letters, :string
      add :creator_name, :string, null: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(:games, [:code])
  end
end
