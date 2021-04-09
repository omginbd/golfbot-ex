defmodule Golfbot.TournamentsFixtures do
  @moduledoc """
  This Module defines test helpers for creating
  entities via the `Golfbot.Tournaments` context.
  """

  alias Golfbot.AccountsFixtures
  alias Golfbot.Tournaments

  def tournament_fixture(attrs \\ %{date: ~D[2010-04-17], name: "some name"}) do
    {:ok, tournament} =
      attrs
      |> Tournaments.create_tournament()

    tournament
  end

  def registration_fixture(attrs \\ %{}) do
    user = AccountsFixtures.user_fixture()
    tournament = tournament_fixture()

    {:ok, registration} =
      attrs
      |> Map.merge(%{tournament_id: tournament.id, user_id: user.id})
      |> Tournaments.create_registration()

    registration
  end
end
