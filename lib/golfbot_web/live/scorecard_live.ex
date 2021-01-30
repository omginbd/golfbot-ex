defmodule GolfbotWeb.ScorecardLive do
  use GolfbotWeb, :live_view
  import GolbotWeb.Helpers.IconHelper

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, holes: holes(), results: %{})}
  end

  @impl true
  def handle_event("suggest", %{"q" => query}, socket) do
    {:noreply, assign(socket, results: search(query), query: query)}
  end

  @impl true
  def handle_event("search", %{"q" => query}, socket) do
    case search(query) do
      %{^query => vsn} ->
        {:noreply, redirect(socket, external: "https://hexdocs.pm/#{query}/#{vsn}")}

      _ ->
        {:noreply,
         socket
         |> put_flash(:error, "No dependencies found matching \"#{query}\"")
         |> assign(results: %{}, query: query)}
    end
  end

  def holes do
    [
      %{
        hole_number: 1,
        prev_score: -1,
        score: 1,
        par: 1,
        dist: "100ft",
        handicap: 1
      }
    ]
  end

  defp search(query) do
    if not GolfbotWeb.Endpoint.config(:code_reloader) do
      raise "action disabled when not in development"
    end

    for {app, desc, vsn} <- Application.started_applications(),
        app = to_string(app),
        String.starts_with?(app, query) and not List.starts_with?(desc, ~c"ERTS"),
        into: %{},
        do: {app, vsn}
  end
end
