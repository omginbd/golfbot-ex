defmodule GolfbotWeb.RsvpLive do
  use GolfbotWeb, :live_view

  alias Golfbot.Tournaments

  @impl true
  def mount(_params, _session, socket) do
    {
      :ok,
      socket
    }
  end

  @impl true
  def handle_params(%{"token" => token}, _uri, socket) do
    case Tournaments.accept_invite(token) do
      {:ok, %Tournaments.Registration{} = _} ->
        {:noreply,
         socket
         |> put_and_clear_flash(:info, "Registration Confirmed, Please Login To Continue")
         |> push_redirect(to: "/auth/google")}

      nil ->
        {:noreply, socket}
    end
  end
end
