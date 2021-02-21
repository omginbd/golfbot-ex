defmodule GolfbotWeb.AdminLive do
  use GolfbotWeb, :live_view
  import GolfbotWeb.MountHelper

  @impl true
  def mount(params, session, socket) do
    {
      :ok,
      socket
      |> assign_user(params, session)
      |> assign(:edit_player, -1)
      |> assign(:players, players())
    }
  end

  @impl true
  def handle_event("edit-name", %{"player_id" => player_id}, socket) do
    {:noreply, assign(socket, :edit_player, String.to_integer(player_id))}
  end

  @impl true
  def handle_event("confirm-name", _params, socket) do
    {:noreply, assign(socket, :edit_player, -1)}
  end

  @impl true
  def handle_event("hide-player", %{"player_id" => player_id}, socket) do
    {:noreply,
     assign(
       socket,
       :players,
       set_player_active(socket.assigns.players, String.to_integer(player_id), false)
     )}
  end

  @impl true
  def handle_event("show-player", %{"player_id" => player_id}, socket) do
    {:noreply,
     assign(
       socket,
       :players,
       set_player_active(socket.assigns.players, String.to_integer(player_id), true)
     )}
  end

  @impl true
  def handle_event("delete-player", %{"player_id" => player_id}, socket) do
    {:noreply,
     assign(
       socket,
       :players,
       Enum.filter(socket.assigns.players, &(&1.id != String.to_integer(player_id)))
     )}
  end

  def set_player_active(players, player_id, active) do
    Enum.map(players, fn player ->
      if player.id == player_id do
        %{player | active: active}
      else
        player
      end
    end)
  end

  def players do
    [
      %{id: 1, first_name: "Michael", last_name: "Collier", active: true},
      %{id: 2, first_name: "Samuel", last_name: "Poulton", active: true}
    ]
  end
end
