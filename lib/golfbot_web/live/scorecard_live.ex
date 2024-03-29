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
      |> assign(:show_gifs, true)
      |> assign(:show_gif_score, -99)
      |> assign_all_scores()
    }
  end

  @impl true
  def handle_params(
        %{"round_number" => round_number, "hole_number" => hole_number} = _params,
        _uri,
        socket
      ) do
    round_number = String.to_integer(round_number)
    hole_number = String.to_integer(hole_number)

    if round_number not in 1..4 or hole_number not in 1..7 do
      clamped_round = round_number |> min(4) |> max(1)
      clamped_hole = hole_number |> min(7) |> max(1)

      {:noreply,
       socket
       |> push_patch(to: Routes.scorecard_path(socket, :index, clamped_round, clamped_hole))}
    else
      {:noreply,
       socket
       |> assign(:cur_round, round_number)
       |> assign_scores_for_round(round_number)
       |> assign_hole_num(hole_number)}
    end
  end

  @impl true
  def handle_params(_params, _uri, socket) do
    cur_round = socket.assigns.all_scores |> get_max_round()

    cur_hole = socket.assigns.all_scores |> get_max_hole(cur_round)

    {:noreply,
     socket |> push_patch(to: Routes.scorecard_path(socket, :index, cur_round, cur_hole))}
  end

  @impl true
  def handle_event("set-round", %{"round" => new_round}, socket) do
    new_round = String.to_integer(new_round)
    max_round = get_max_round(socket.assigns.all_scores)

    if new_round <= max_round do
      {:noreply,
       socket
       |> push_patch(to: Routes.scorecard_path(socket, :index, new_round, 1))}
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

    hole = course() |> Enum.find(&(&1.hole_number == new_score.hole_num))

    gif_score =
      cond do
        not socket.assigns.show_gifs -> -99
        new_score.value == 1 -> -80
        true -> new_score.value - hole.par
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
        %{"score" => score, "hole" => hole_num, "round" => round_num, "gif" => show_gif},
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

    hole = course() |> Enum.find(&(&1.hole_number == new_score.hole_num))

    gif_score =
      cond do
        not show_gif -> -99
        not socket.assigns.show_gifs -> -99
        new_score.value == 1 -> -80
        true -> new_score.value - hole.par
      end

    {:noreply,
     socket
     |> assign_new_score(new_score)
     |> maybe_assign_scores_for_round(new_score)
     |> assign(:show_gif_score, gif_score)
     |> maybe_progress_round(String.to_integer(hole_num))}
  end

  @impl true
  def handle_event("dont-show-gifs", _params, socket) do
    {:noreply,
     socket
     |> assign(:show_gifs, false)
     |> assign(:show_gif_score, -99)}
  end

  @impl true
  def handle_event(event, params, socket) do
    IO.inspect({event, params}, label: "uncaught event")
    {:noreply, socket}
  end

  @impl true
  def handle_info("hide-gif", socket) do
    {:noreply,
     socket
     |> assign(:show_gif_score, -99)}
  end

  def get_max_hole([], _round) do
    1
  end

  def get_max_hole(scores, cur_round) do
    scores
    |> Enum.filter(&(&1.round_num === cur_round))
    |> Enum.map(& &1.hole_num)
    |> Enum.max(fn -> 1 end)
    |> Kernel.+(1)
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
      |> push_patch(to: Routes.scorecard_path(socket, :index, new_round))
      |> put_flash(:info, "Round #{socket.assigns.cur_round} Complete!")
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
  def get_score_title(-3), do: "Albatross"
  def get_score_title(-2), do: "Eagle"
  def get_score_title(-1), do: "Birdie"
  def get_score_title(0), do: "Par"
  def get_score_title(1), do: "Bogey"
  def get_score_title(2), do: "Double Bogey"
  def get_score_title(3), do: "Triple Bogey"
  def get_score_title(4), do: "Four Over"
  def get_score_title(5), do: "Five Over"
  def get_score_title(_n), do: ""

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

  def assign_hole_num(socket, cur_hole) do
    hole_num = (length(socket.assigns.scores) + 1) |> min(7)

    if cur_hole !== hole_num do
      socket
      |> push_patch(to: Routes.scorecard_path(socket, :index, socket.assigns.cur_round, hole_num))
    else
      socket
      |> assign(:cur_hole, hole_num)
    end
  end

  def course do
    Golfbot.Course.course()
  end

  def gif(-80) do
    [
      "https://i.giphy.com/keUq2HMCXjQrMBy11F.gif",
      "https://c.tenor.com/2_q3Ev9CoJIAAAAM/hole-in-one-golf.gif"
    ]
    |> Enum.shuffle()
    |> hd()
  end

  def gif(-2) do
    [
      "https://i.giphy.com/3ohA2GnDgeDgRnTYac.gif",
      "https://i.giphy.com/XZsuGblA9PmT0PD3HA.gif",
      "https://c.tenor.com/vlh8OPVWVewAAAAM/golf-celebration.gif",
      "https://c.tenor.com/JpBVzmg5VXYAAAAM/golf.gif"
    ]
    |> Enum.shuffle()
    |> hd()
  end

  def gif(-1) do
    [
      "https://i.giphy.com/Zn7rsVqBTPAly.gif",
      "https://i.giphy.com/IdlCPeewygc8eaX1Tb.gif",
      "https://c.tenor.com/3UMW3BdbjoUAAAAM/win-yes.gif",
      "https://c.tenor.com/bOwkt15ncwIAAAAM/shooter-happygilmore.gif",
      "https://i.giphy.com/xUOwG43OJ9Mzf4exQQ.gif"
    ]
    |> Enum.shuffle()
    |> hd()
  end

  def gif(0) do
    [
      "https://i.giphy.com/OPl1CmAfplB1C.gif",
      "https://i.giphy.com/e8YwqjYiQxB5LKSf8t.gif",
      "https://c.tenor.com/kAmrnBsstoYAAAAM/putt-inbee-park.gif",
      "https://c.tenor.com/-Zrk-2ywCTUAAAAM/shooter-mcgavin.gif",
      "https://i.giphy.com/akiHW8qDydkm4.gif",
      "https://i.makeagif.com/media/3-31-2016/0AbB7A.gif"
    ]
    |> Enum.shuffle()
    |> hd()
  end

  def gif(1) do
    [
      "https://i.giphy.com/sfLVSPDJHDLSo.gif",
      "https://i.giphy.com/yCdmeyPCU2b1C.gif",
      "https://c.tenor.com/autF2i4Xp1oAAAAM/golf-golfing.gif",
      "https://c.tenor.com/3Htw_sKvGx4AAAAM/golf-is.gif",
      "https://c.tenor.com/eiVVVgauqAcAAAAd/charles-barkley-golf.gif",
      "https://adamsarson.files.wordpress.com/2013/12/07-28-13-greg-owen-club-smash.gif"
    ]
    |> Enum.shuffle()
    |> hd()
  end

  def gif(2) do
    [
      "https://i.giphy.com/146YfoNq3cuM7u.gif",
      "https://i.giphy.com/HqZSbR8DPGIo0.gif",
      "https://c.tenor.com/McwYCtgrIooAAAAM/choppa-golf-mad.gif",
      "https://adamsarson.files.wordpress.com/2013/12/christian-kicks-ball.gif"
    ]
    |> Enum.shuffle()
    |> hd()
  end

  def gif(n) when n == 3 or n == 4 or n == 5 do
    [
      "https://i.giphy.com/2t8jyWKydrHcQ.gif",
      "https://i.giphy.com/58FqqvATAS9DIQ7dNJ.gif",
      "https://c.tenor.com/Es4H-0H62UEAAAAM/golf-golfing.gif",
      "https://c.tenor.com/eLQWG2CrQ5gAAAAM/the-office-dwight-schrute.gif",
      "https://i.makeagif.com/media/7-28-2018/ek0GLi.gif"
    ]
    |> Enum.shuffle()
    |> hd()
  end

  def gif(_n), do: "https://i.giphy.com/L3oTUQIDkDJzRu6mzF.gif"
end
