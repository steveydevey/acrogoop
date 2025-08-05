defmodule Acrogoop.Repo.Migrations.CreateSubmissionsTable do
  use Ecto.Migration

  def change do
    create table(:submissions, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :phrase, :string, null: false
      add :round_number, :integer, null: false
      add :submitted_at, :utc_datetime, null: false
      add :game_id, references(:games, type: :binary_id, on_delete: :delete_all), null: false
      add :player_id, references(:players, type: :binary_id, on_delete: :delete_all), null: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(:submissions, [:game_id, :player_id, :round_number])
    create index(:submissions, [:game_id])
    create index(:submissions, [:player_id])
  end
end
