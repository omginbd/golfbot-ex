defmodule Golfbot.Repo.Migrations.CreateScores do
  use Ecto.Migration

  def change do
    create table(:scores) do
      add :hole_num, :integer
      add :round_num, :integer
      add :value, :integer
      add :registration_id, references(:registrations, on_delete: :nothing)

      timestamps()
    end

    create index(:scores, [:registration_id])
  end
end
