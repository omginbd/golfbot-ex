defmodule Golfbot.Repo.Migrations.CreateInviteTable do
  use Ecto.Migration

  def change do
    create table(:invitations) do
      add(:tournament_id, references(:tournaments, on_delete: :delete_all))
      add(:email, :string)
      add(:token, :string)

      timestamps()
    end

    unique_index(:invitations, [:token])
  end
end
