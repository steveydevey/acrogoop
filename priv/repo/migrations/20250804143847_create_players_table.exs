defmodule Acrogoop.Repo.Migrations.CreatePlayersTable do
  use Ecto.Migration

  def change do
    create table(:players, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string, null: false
      add :session_id, :string, null: false
      add :score, :integer, null: false, default: 0
      add :is_creator, :boolean, null: false, default: false
      add :game_id, references(:games, type: :binary_id, on_delete: :delete_all), null: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(:players, [:session_id, :game_id])
    create index(:players, [:game_id])
  end
end
