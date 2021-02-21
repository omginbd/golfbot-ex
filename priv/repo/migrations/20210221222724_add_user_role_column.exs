defmodule Golfbot.Repo.Migrations.AddUserRoleColumn do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add(:user_role, :integer, default: 0)
    end
  end
end
