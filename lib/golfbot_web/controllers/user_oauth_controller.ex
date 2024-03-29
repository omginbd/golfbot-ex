defmodule GolfbotWeb.UserOauthController do
  use GolfbotWeb, :controller

  alias Golfbot.Accounts
  alias GolfbotWeb.UserAuth

  @rand_pass_length 32

  # def callback(%{assigns: %{ueberauth_auth: %{info: user_info}}} = conn, %{"provider" => "google"}) do
  # user_params = %{
  #   email: user_info.email,
  #   first_name: user_info.first_name,
  #   last_name: user_info.last_name,
  #   profile_image: user_info.image,
  #   password: random_password()
  # }

  # case Accounts.fetch_or_create_user(user_params) do
  #   {:ok, user} ->
  #     UserAuth.log_in_user(conn, user)

  #   failed_to_create ->
  #     IO.inspect(failed_to_create)

  #     conn
  #     |> put_flash(:error, "Authentication failed")
  #     |> redirect(to: "/")
  # end
  # conn
  # end

  def callback(conn, _params) do
    conn
    |> put_flash(:error, "Authentication failed")
    |> redirect(to: "/")
  end

  def random_password do
    :crypto.strong_rand_bytes(@rand_pass_length) |> Base.encode64()
  end
end
