defmodule Golfbot.Repo.Migrations.CreateRegistrations do
  use Ecto.Migration

  def change do
    create table(:registrations) do
      add(:has_paid, :boolean, default: false, null: false)
      add(:tournament_id, references(:tournaments, on_delete: :delete_all))
      add(:user_id, references(:users, on_delete: :nothing))

      timestamps()
    end

    create(index(:registrations, [:tournament_id]))
    create(index(:registrations, [:user_id]))
  end
end
