defmodule GolfbotWeb.ScorecardLive do
  use GolfbotWeb, :live_view
  import GolbotWeb.Helpers.IconHelper
  alias Golfbot.Score

  @impl true
  def mount(_params, _session, socket) do
    {
      :ok,
      socket
      |> assign(:cur_round, 1)
      |> assign(:cur_score, -1)
      |> assign(:cur_hole, -1)
    }
  end

  @impl true
  def handle_event("next-round", _params, socket) do
    {:noreply, assign(socket, :cur_round, min(socket.assigns.cur_round + 1, 4))}
  end

  @impl true
  def handle_event("prev-round", _params, socket) do
    {:noreply, assign(socket, :cur_round, max(socket.assigns.cur_round - 1, 1))}
  end

  @impl true
  def handle_event("open-scorer", %{"hole_number" => hole_num}, socket) do
    {
      :noreply,
      socket
      |> assign(:cur_hole, hole_num)
      |> assign(
        :cur_score,
        Enum.find(course(), &(&1.hole_number == String.to_integer(hole_num))).par
      )
    }
  end

  @impl true
  def handle_event("minus-score", _params, socket) do
    {
      :noreply,
      socket
      |> assign(:cur_score, max(socket.assigns.cur_score - 1, 0))
    }
  end

  @impl true
  def handle_event("plus-score", _params, socket) do
    {
      :noreply,
      socket
      |> assign(:cur_score, min(socket.assigns.cur_score + 1, 9))
    }
  end

  def course do
    [
      %{
        hole_number: 1,
        par: 5,
        dist: 128,
        handicap: 3
      },
      %{
        hole_number: 2,
        par: 4,
        dist: 59,
        handicap: 2
      },
      %{
        hole_number: 3,
        par: 3,
        dist: 58,
        handicap: 5
      },
      %{
        hole_number: 4,
        par: 4,
        dist: 70,
        handicap: 4
      },
      %{
        hole_number: 5,
        par: 4,
        dist: 71,
        handicap: 7
      },
      %{
        hole_number: 6,
        par: 4,
        dist: 76,
        handicap: 6
      },
      %{
        hole_number: 7,
        par: 4,
        dist: 99,
        handicap: 1
      }
    ]
  end
end
