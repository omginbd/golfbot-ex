defmodule GolfbotWeb.ScorecardLive do
  use GolfbotWeb, :live_view
  import GolfbotWeb.MountHelper

  alias Golfbot.Scores

  @topic "new_score"

  @impl true
  def mount(params, session, socket) do
    {
      :ok,
      socket
      |> assign_user(params, session)
      |> assign(:cur_round, 1)
      |> assign(:show_gif_score, -99)
      |> assign_all_scores()
      |> assign_scores_for_round(1)
    }
  end

  @impl true
  def handle_event("set-round", %{"round" => new_round}, socket) do
    new_round = String.to_integer(new_round)
    max_round = get_max_round(socket.assigns.all_scores)

    if new_round <= max_round do
      {:noreply,
       socket
       |> assign(:cur_round, new_round)
       |> assign_scores_for_round(new_round)}
    else
      {:noreply, socket}
    end
  end

  @impl true
  def handle_event("hide-gif", _params, socket) do
    {:noreply,
     socket
     |> assign(:show_gif_score, -99)}
  end

  @impl true
  def handle_event("set-score", %{"score" => score, "hole" => hole_num}, socket) do
    {:ok, new_score} =
      Scores.upsert_score(%{
        registration_id: socket.assigns.current_user.registrations |> hd |> Map.get(:id),
        hole_num: hole_num,
        round_num: socket.assigns.cur_round,
        value: score
      })

    Phoenix.PubSub.broadcast(Golfbot.PubSub, @topic, new_score)

    # Process.send_after(self(), "hide-gif", 5000)

    hole = course() |> Enum.find(&(&1.hole_number == new_score.hole_num))

    gif_score =
      if new_score.value == 1 do
        -80
      else
        new_score.value - hole.par
      end

    {:noreply,
     socket
     |> assign_new_score(new_score)
     |> assign_scores_for_round(socket.assigns.cur_round)
     |> maybe_progress_round(String.to_integer(hole_num))
     |> assign(:show_gif_score, gif_score)}
  end

  @impl true
  def handle_event(
        "set-round-score",
        %{"score" => score, "hole" => hole_num, "round" => round_num},
        socket
      ) do
    {:ok, new_score} =
      Scores.upsert_score(%{
        registration_id: socket.assigns.current_user.registrations |> hd |> Map.get(:id),
        hole_num: hole_num,
        round_num: round_num,
        value: score
      })

    Phoenix.PubSub.broadcast(Golfbot.PubSub, @topic, new_score)

    {:noreply,
     socket
     |> assign_new_score(new_score)
     |> maybe_assign_scores_for_round(new_score)
     |> assign(:show_gif_score, -99)
     |> maybe_progress_round(String.to_integer(hole_num))}
  end

  @impl true
  def handle_info("hide-gif", socket) do
    {:noreply,
     socket
     |> assign(:show_gif_score, -99)}
  end

  def get_max_round([]) do
    1
  end

  def get_max_round(scores) do
    score_count =
      scores
      |> Enum.frequencies_by(& &1.round_num)

    max_round =
      score_count
      |> Map.keys()
      |> Enum.max()

    case Map.get(score_count, max_round) do
      7 -> max_round + 1
      _ -> max_round
    end
  end

  def maybe_progress_round(socket, hole_num) do
    if hole_num == 7 and length(socket.assigns.scores) == 7 do
      new_round = min(4, socket.assigns.cur_round + 1)

      socket
      |> assign(:cur_round, new_round)
      |> assign_scores_for_round(new_round)
    else
      socket
    end
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

  def maybe_assign_scores_for_round(socket, score) do
    if socket.assigns.cur_round == score.round_num do
      assign_scores_for_round(socket, socket.assigns.cur_round)
    else
      socket
    end
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

  def get_over_under_for_hole(hole, scores) do
    num =
      scores
      |> Enum.find(%{}, &(&1.hole_num == hole.hole_number))
      |> Map.get(:value, "")

    get_over_under_for_score(num, hole.par)
  end

  def get_over_under_for_score("", _par), do: ""
  def get_over_under_for_score(0, _par), do: ""
  def get_over_under_for_score(score, score), do: "E"
  def get_over_under_for_score(score, par) when score - par > 0, do: "+#{score - par}"
  def get_over_under_for_score(score, par), do: score - par

  def get_score_title(-80), do: "Hole in One"
  def get_score_title(-2), do: "Eagle"
  def get_score_title(-1), do: "Birdie"
  def get_score_title(0), do: "Par"
  def get_score_title(1), do: "Bogey"
  def get_score_title(2), do: "Double Bogey"
  def get_score_title(3), do: "Triple Bogey"
  def get_score_title(_n), do: "Too Much"

  def get_score_for_hole(hole, scores) do
    scores
    |> Enum.find(%{}, &(&1.hole_num == hole.hole_number))
    |> Map.get(:value, "")
  end

  def calculate_round_par(scores) do
    par = course_par()

    course()
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
    Golfbot.Course.course()
  end

  def gif do
    [
      "https://i.giphy.com/127h8dMHnk5H5C.gif",
      "https://i.giphy.com/5uF0PN4Dai6SA.gif",
      "https://i.giphy.com/GB4N7W7OP5iOk.gif",
      "https://i.giphy.com/IIcOE54NUreEg.gif",
      "https://i.giphy.com/IYJBTNLgES23K.gif"
    ]
    |> Enum.shuffle()
    |> hd()
  end
end
