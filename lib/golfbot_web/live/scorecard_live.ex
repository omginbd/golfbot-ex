defmodule GolfbotWeb.ScorecardLive do
  use GolfbotWeb, :live_view
  import GolbotWeb.Helpers.IconHelper
  import GolfbotWeb.MountHelper

  alias Golfbot.Scores

  @impl true
  def mount(params, session, socket) do
    {
      :ok,
      socket
      |> assign_user(params, session)
      |> assign(:cur_round, 1)
      |> assign(:cur_score, -1)
      |> assign(:cur_hole, "-1")
      |> assign(:prev_round_scores, [])
      |> assign_all_scores()
      |> assign_scores_for_round(1)
    }
  end

  @impl true
  def handle_event("next-round", _params, socket) do
    new_round = min(socket.assigns.cur_round + 1, 4)

    {
      :noreply,
      socket
      |> assign(:cur_round, new_round)
      |> assign_scores_for_round(new_round)
      |> assign(
        :prev_round_scores,
        get_scores_for_round(socket.assigns.all_scores, new_round - 1)
      )
    }
  end

  @impl true
  def handle_event("prev-round", _params, socket) do
    new_round = max(socket.assigns.cur_round - 1, 1)

    {
      :noreply,
      socket
      |> assign(:cur_round, new_round)
      |> assign_scores_for_round(new_round)
      |> assign(
        :prev_round_scores,
        get_scores_for_round(socket.assigns.all_scores, new_round - 1)
      )
    }
  end

  @impl true
  def handle_event("open-scorer", %{"hole_number" => hole_num}, socket) do
    score =
      case Enum.find(
             socket.assigns.all_scores,
             &(&1.hole_num == String.to_integer(hole_num) and
                 &1.round_num ==
                   socket.assigns.cur_round)
           ) do
        nil -> Enum.find(course(), &(&1.hole_number == String.to_integer(hole_num))).par
        s -> s.value
      end

    {
      :noreply,
      socket
      |> assign(:cur_hole, hole_num)
      |> assign(:cur_score, score)
    }
  end

  @impl true
  def handle_event("minus-score", _params, socket) do
    {
      :noreply,
      socket
      |> assign(:cur_score, max(socket.assigns.cur_score - 1, 1))
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

  @impl true
  def handle_event("confirm-score", _params, socket) do
    {:ok, new_score} =
      Scores.upsert_score(%{
        registration_id: socket.assigns.current_user.registrations |> hd |> Map.get(:id),
        hole_num: socket.assigns.cur_hole,
        round_num: socket.assigns.cur_round,
        value: socket.assigns.cur_score
      })

    {:noreply,
     socket
     |> assign(:cur_hole, "-1")
     |> assign_new_score(new_score)
     |> assign_scores_for_round(socket.assigns.cur_round)}
  end

  def assign_new_score(socket, new_score) do
    new_scores = [
      new_score
      | socket.assigns.all_scores
        |> Enum.reject(&(&1.id == new_score.id))
    ]

    assign(socket, :all_scores, new_scores)
  end

  def assign_all_scores(socket) do
    assign(
      socket,
      :all_scores,
      socket.assigns.current_user.registrations
      |> hd
      |> Map.get(:scores)
    )
  end

  def assign_scores_for_round(socket, round_num) do
    assign(socket, :scores, get_scores_for_round(socket.assigns.all_scores, round_num))
  end

  def get_scores_for_round(all_scores, round) do
    all_scores
    |> Enum.group_by(& &1.round_num)
    |> Map.get(round, [])
    |> Enum.sort_by(& &1.hole_num)
  end

  def get_score_for_hole(hole, cur_hole, cur_score, scores) do
    if hole.hole_number == String.to_integer(cur_hole) do
      cur_score
    else
      scores
      |> Enum.find(%{}, &(&1.hole_num == hole.hole_number))
      |> Map.get(:value, "")
    end
  end

  def calculate_round_par(scores) do
    par = course_par

    score =
      course
      |> Enum.map(fn hole ->
        case Enum.find(scores, &(&1.hole_num == hole.hole_number)) do
          nil -> hole.par
          s -> s.value
        end
      end)
      |> Enum.sum()
      |> case do
        n when n > par -> "+#{n - par}"
        n when n == par -> "Even"
        n when n < par -> "-#{par - n}"
      end
  end

  def course_par do
    course()
    |> Enum.map(& &1.par)
    |> Enum.sum()
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
