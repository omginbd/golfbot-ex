defmodule Golfbot.Tournaments.Invitation do
  use Ecto.Schema
  import Ecto.Changeset

  alias Golfbot.Tournaments.Tournament

  schema "invitations" do
    field :token, :string

    belongs_to :tournament, Tournament

    timestamps()
  end

  @doc false
  def changeset(invitation, attrs \\ %{}) do
    invitation
    |> cast(attrs, [:token, :tournament_id])
    |> validate_required([:token, :tournament_id])
  end
end
