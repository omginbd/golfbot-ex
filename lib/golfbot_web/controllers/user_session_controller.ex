defmodule GolfbotWeb.UserSessionController do
  use GolfbotWeb, :controller

  alias Golfbot.Accounts
  alias GolfbotWeb.UserAuth

  def new(conn, _params) do
    render(conn, "new.html", error_message: nil)
  end

  def create(conn, %{"user" => user_params}) do
    case Accounts.register_user(user_params) do
      {:ok, user} -> UserAuth.log_in_user(conn, user)
      _ -> render(conn, "new.html", error_message: "Invalid User Info")
    end
  end

  def delete(conn, _params) do
    conn
    |> put_flash(:info, "Logged out successfully.")
    |> UserAuth.log_out_user()
  end
end
