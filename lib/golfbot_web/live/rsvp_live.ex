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
  def handle_params(%{"tournament_id" => tournament_id}, _uri, socket) do
    tournament = Tournaments.get_tournament!(tournament_id)
    {:noreply, socket |> assign(:tournament, tournament)}
  end
end
