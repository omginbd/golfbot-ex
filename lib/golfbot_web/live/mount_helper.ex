defmodule GolfbotWeb.MountHelper do
  import Phoenix.LiveView
  alias Golfbot.Accounts

  def assign_user(socket, _params, session) do
    assign_new(socket, :current_user, fn ->
      Accounts.get_user_by_session_token!(session["user_token"])
      |> Golfbot.Repo.preload(:registrations)
    end)
  end
end
