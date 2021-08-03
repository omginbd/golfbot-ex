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
tournament =
  %Golfbot.Tournaments.Tournament{
    name: "Wiffle Ball Open 2021",
    date: ~D[2021-08-28]
  }
  |> Golfbot.Repo.insert!()

# Make superadmin user
admin =
  Golfbot.Accounts.register_user(%{
    first_name: "admin",
    last_name: "admin"
  })
