defmodule Acrogoop.Repo.Migrations.CreateVotesTable do
  use Ecto.Migration

  def change do
    create table(:votes, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :round_number, :integer, null: false
      add :game_id, references(:games, type: :binary_id, on_delete: :delete_all), null: false
      add :player_id, references(:players, type: :binary_id, on_delete: :delete_all), null: false
      add :submission_id, references(:submissions, type: :binary_id, on_delete: :delete_all), null: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(:votes, [:game_id, :player_id, :round_number])
    create index(:votes, [:game_id])
    create index(:votes, [:submission_id])
  end
end
