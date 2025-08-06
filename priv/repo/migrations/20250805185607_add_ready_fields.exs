defmodule Acrogoop.Repo.Migrations.AddReadyFields do
  use Ecto.Migration

  def change do
    alter table(:games) do
      add :ready_players, {:array, :binary_id}, default: []
    end

    alter table(:players) do
      add :is_ready, :boolean, default: false
    end
  end
end
