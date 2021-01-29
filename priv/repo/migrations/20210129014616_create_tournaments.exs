defmodule Golfbot.Repo.Migrations.CreateTournaments do
  use Ecto.Migration

  def change do
    create table(:tournaments) do
      add :name, :string
      add :date, :date

      timestamps()
    end

  end
end
