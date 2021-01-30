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
