defmodule Golfbot.Repo.Migrations.MoveRoleColumnToRegistration do
  use Ecto.Migration

  def change do
    alter table(:users) do
      remove_if_exists(:user_role, :integer)
    end

    alter table(:registrations) do
      add_if_not_exists(:role, :integer, default: 0)
    end
  end
end
