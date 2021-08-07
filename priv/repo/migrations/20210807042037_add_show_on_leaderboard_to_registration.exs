defmodule Golfbot.Repo.Migrations.AddShowOnLeaderboardToRegistration do
  use Ecto.Migration

  def change do
    alter table(:registrations) do
      add_if_not_exists(:show_on_leaderboard, :boolean, default: true)
    end
  end
end
