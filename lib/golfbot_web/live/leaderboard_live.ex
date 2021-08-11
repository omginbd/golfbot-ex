defmodule GolfbotWeb.LeaderboardLive do
  use GolfbotWeb, :live_view
  import GolfbotWeb.MountHelper

  alias Golfbot.Scores
  alias Golfbot.Tournaments
  import Golfbot.Course

  @topic "new_score"

  @impl true
  def mount(params, session, socket) do
    GolfbotWeb.Endpoint.subscribe(@topic)

    {
      :ok,
      socket
      |> assign_user(params, session)
      |> assign_tournament()
    }
  end

  @impl true
  def handle_info(%Scores.Score{} = score, socket) do
    tournament =
      %{socket.assigns.tournament | registrations: assign_new_score(socket, score)}
      |> sort_registrations

    position_map = build_position_map(tournament.registrations)

    {:noreply,
     socket
     |> assign(:tournament, tournament)
     |> assign(:position_map, position_map)}
  end

  defp assign_new_score(socket, score) do
    socket.assigns.tournament.registrations
    |> Enum.map(fn reg ->
      if reg.id == score.registration_id do
        %{reg | scores: [score | reg.scores |> Enum.reject(&(&1.id == score.id))]}
      else
        reg
      end
    end)
  end

  def assign_tournament(socket) do
    tournament =
      Tournaments.get_tournament!(1) |> sort_registrations |> filter_hidden_registrations

    position_map = build_position_map(tournament.registrations)

    socket
    |> assign(:tournament, tournament)
    |> assign(:position_map, position_map)
  end

  def build_position_map(registrations, cur_pos \\ 1, last_score \\ -1, cur_map \\ %{})

  def build_position_map([head | tail], cur_pos, last_score, cur_map) do
    case get_tournament_score(head.scores) |> Enum.sum() do
      ^last_score ->
        build_position_map(tail, cur_pos, last_score, Map.put(cur_map, head.id, ""))

      score ->
        build_position_map(tail, cur_pos + 1, score, Map.put(cur_map, head.id, cur_pos))
    end
  end

  def build_position_map([], _cur_pos, _last_score, cur_map), do: cur_map

  def sort_registrations(tournament) do
    %{
      tournament
      | registrations:
          tournament.registrations
          |> Enum.sort_by(
            &{get_tournament_score(&1.scores) |> Enum.sum(), 28 - length(&1.scores)}
          )
    }
  end

  def filter_hidden_registrations(tournament) do
    %{
      tournament
      | registrations:
          tournament.registrations
          |> Enum.filter(& &1.show_on_leaderboard)
    }
  end

  def get_display_name(first_name, last_name) do
    "#{last_name} #{String.graphemes(first_name) |> hd}."
  end

  def get_tournament_score(scores) do
    for round <- 1..4 do
      course()
      |> Enum.map(fn hole ->
        case Enum.find(scores, &(&1.hole_num == hole.hole_number and &1.round_num == round)) do
          nil -> hole.par
          s -> s.value
        end
      end)
      |> Enum.sum()
    end
  end

  def get_overall_class(overall) do
    cond do
      String.starts_with?(overall, "-") -> "under"
      overall == "Even" -> "even"
      true -> ""
    end
  end

  def calculate_tournament_par(scores) do
    par = course() |> Enum.map(& &1.par) |> Enum.sum() |> Kernel.*(4)
    padded_scores = get_tournament_score(scores)

    padded_scores
    |> List.flatten()
    |> Enum.sum()
    |> case do
      n when n > par -> "+#{n - par}"
      n when n == par -> "Even"
      n when n < par -> "-#{par - n}"
    end
  end

  defp pad_scores(scores) do
    for round_num <- 1..4 do
      for hole <- Golfbot.Course.course() do
        case Enum.find(scores, &(&1.round_num == round_num and &1.hole_num == hole.hole_number)) do
          nil -> {get_class(hole, nil), ""} |> maybe_first_hole(hole)
          s -> {get_class(hole, s), s.value} |> maybe_first_hole(hole)
        end
      end
    end
  end

  defp maybe_first_hole({class, value}, %{hole_number: hole_number}) when hole_number == 1,
    do: {"#{class} first-hole", value}

  defp maybe_first_hole(original, _), do: original

  defp get_class(_hole, nil), do: ""
  defp get_class(%{par: par}, %{value: value}) when par == value, do: "par"
  defp get_class(_hole, %{value: value}) when value == 1, do: "ace"
  defp get_class(%{par: par}, %{value: value}) when par - value == 1, do: "birdie"
  defp get_class(%{par: par}, %{value: value}) when par - value == 2, do: "eagle"
  defp get_class(%{par: par}, %{value: value}) when par - value == 3, do: "albatross"
  defp get_class(%{par: par}, %{value: value}) when value - par == 3, do: "triple-bogie"
  defp get_class(%{par: par}, %{value: value}) when value - par == 2, do: "double-bogie"
  defp get_class(%{par: par}, %{value: value}) when value - par == 1, do: "bogie"
  defp get_class(_hole, _score), do: "bad"
end
