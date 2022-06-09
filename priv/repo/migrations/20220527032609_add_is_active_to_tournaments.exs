defmodule Golfbot.Repo.Migrations.AddIsActiveToTournaments do
  use Ecto.Migration

  def change do
    alter table(:tournaments) do
      add_if_not_exists(:is_active, :boolean, default: false)
    end
  end
end
