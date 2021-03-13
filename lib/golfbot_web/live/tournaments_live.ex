defmodule GolfbotWeb.TournamentsLive do
  use GolfbotWeb, :live_view
  import GolfbotWeb.MountHelper

  alias Golfbot.Tournaments

  @email_regex ~r/^[\w.!#$%&’*+\-\/=?\^`{|}~]+@[a-zA-Z0-9-]+(\.[a-zA-Z0-9-]+)*$/i

  @impl true
  def mount(params, session, socket) do
    {
      :ok,
      socket
      |> assign_user(params, session)
      |> assign(:modal_open, false)
      |> assign(:tournaments, get_tournaments())
      |> assign(:mode, nil)
    }
  end

  @impl true
  def handle_event("set-create-modal-open", %{"open" => is_open?}, socket) do
    case is_open? do
      "true" ->
        {:noreply,
         socket
         |> assign(:modal_open, true)
         |> assign(:mode, :create)
         |> assign(
           :create_tournament_changeset,
           Tournaments.change_tournament(%Tournaments.Tournament{})
         )}

      _ ->
        {:noreply,
         socket
         |> assign(:modal_open, false)
         |> assign(:mode, nil)
         |> assign(:create_tournament_changeset, nil)}
    end
  end

  @impl true
  def handle_event("save-tournament", %{"tournament" => attrs}, socket) do
    result =
      socket.assigns.mode
      |> case do
        :create ->
          attrs
          |> Tournaments.create_tournament()

        :edit ->
          socket.assigns.create_tournament_changeset.data.id
          |> Tournaments.get_tournament!()
          |> Tournaments.update_tournament(attrs)
      end

    case result do
      {:ok, _cs} ->
        Process.send_after(self(), :clear_flash, 5000)

        {:noreply,
         socket
         |> assign(:modal_open, false)
         |> put_and_clear_flash(:info, "Tournament Saved Successfully")
         |> assign(:mode, nil)
         |> assign(:create_tournament_changeset, nil)
         |> assign(:tournaments, get_tournaments())}

      {:error, cs} ->
        {:noreply,
         socket
         |> assign(:create_tournament_changeset, cs)}
    end
  end

  @impl true
  def handle_event("invite", %{"id" => id}, socket) do
    {:noreply,
     socket
     |> assign(:modal_open, true)
     |> assign(:tournament_id, id)
     |> assign(:mode, :invite)}
  end

  @impl true
  def handle_event("edit", %{"id" => id}, socket) do
    {:noreply,
     socket
     |> assign(:modal_open, true)
     |> assign(:mode, :edit)
     |> assign(
       :create_tournament_changeset,
       Tournaments.get_tournament!(id)
       |> Tournaments.change_tournament()
     )}
  end

  @impl true
  def handle_event("save-edit", %{"tournament" => attrs}, socket) do
    socket.assigns.create_tournament_changeset.data.id
    |> Tournaments.get_tournament!()
    |> Tournaments.update_tournament(attrs)
    |> case do
      {:ok, _cs} ->
        {:noreply,
         socket
         |> assign(:modal_open, false)
         |> assign(:mode, nil)
         |> assign(:create_tournament_changeset, nil)}

      {:error, cs} ->
        {:noreply,
         socket
         |> assign(:create_tournament_changeset, cs)}
    end
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    Tournaments.get_tournament!(id)
    |> Tournaments.delete_tournament()
    |> case do
      {:ok, _cs} ->
        {:noreply,
         socket
         |> put_and_clear_flash(:info, "Tournament Deleted")
         |> assign(:tournaments, get_tournaments())}

      {:error, _cs} ->
        {:noreply,
         socket
         |> put_and_clear_flash(:error, "Unable to Delete Tournament")
         |> assign(:tournaments, get_tournaments())}
    end
  end

  @impl true
  def handle_event("send-invites", %{"form" => %{"invitees" => invitees}}, socket) do
    tournament =
      socket.assigns.tournament_id
      |> Tournaments.get_tournament!()

    invitations =
      invitees
      |> String.split(",", trim: true)
      |> Enum.filter(&String.match?(&1, @email_regex))
      |> Enum.map(&Tournaments.invite_to_tournament!(tournament, &1))

    IO.inspect(invitations)

    {:noreply,
     socket
     |> assign(:modal_open, false)
     |> assign(:tournament_id, nil)
     |> assign(:mode, nil)
     |> put_and_clear_flash(:info, "Invites Sent")}
  end

  defp get_tournaments() do
    Tournaments.list_tournaments()
    |> Enum.sort_by(& &1.date)
    |> Enum.reverse()
  end

  defp format_date(date) do
    "#{date.day}/#{date.month}/#{date.year}"
  end
end
