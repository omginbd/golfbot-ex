# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Golfbot.Repo.insert!(%Golfbot.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.
#

# Make superadmin user
Golfbot.Accounts.register_user(%{
  email: "a@a.a",
  password: "password",
  first_name: "admin",
  last_name: "admin"
})
|> case do
  {:ok, user} ->
    Ecto.Changeset.change(user, %{email: "admin"}) |> Golfbot.Repo.update!()

  _ ->
    nil
end

{:ok, me} =
  Golfbot.Accounts.register_user(%{
    email: "colliermichaelp@gmail.com",
    password: "password",
    first_name: "Michael",
    last_name: "Collier"
  })

tournament =
  %Golfbot.Tournaments.Tournament{
    name: "Wiffle Ball Open 2021",
    date: Date.utc_today()
  }
  |> Golfbot.Repo.insert!()

registration =
  %Golfbot.Tournaments.Registration{
    has_paid: true,
    tournament_id: tournament.id,
    user_id: me.id
  }
  |> Golfbot.Repo.insert!()

%Golfbot.Scores.Score{
  hole_num: 1,
  round_num: 1,
  value: 1,
  registration_id: registration.id
}
|> Golfbot.Repo.insert!()
