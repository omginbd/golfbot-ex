defmodule GolfbotWeb.UserSessionController do
  use GolfbotWeb, :controller

  alias Golfbot.Accounts
  alias GolfbotWeb.UserAuth

  def new(conn, _params) do
    redirect(conn, to: "/leaderboard")
    # render(conn, "new.html", changeset: Golfbot.Accounts.User.empty_changeset())
  end

  def create(conn, %{"user" => user_params}) do
    Accounts.get_or_create_user(user_params)
    |> case do
      {:ok, user} -> UserAuth.log_in_user(conn, user)
      {:error, changeset} -> render(conn, "new.html", changeset: changeset)
      _ -> render(conn, "new.html", changeset: Golfbot.Accounts.User.empty_changeset())
    end
  end

  def delete(conn, _params) do
    conn
    |> put_flash(:info, "Logged out successfully.")
    |> UserAuth.log_out_user()
  end
end
