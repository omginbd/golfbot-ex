defmodule Golfbot.Tournaments.Registration do
  use Ecto.Schema
  import Ecto.Changeset

  alias Golfbot.Scores.Score

  schema "registrations" do
    field :has_paid, :boolean, default: false
    field :tournament_id, :id
    field :user_id, :id

    has_many :scores, Score

    timestamps()
  end

  @doc false
  def changeset(registration, attrs) do
    registration
    |> cast(attrs, [:has_paid])
    |> validate_required([:has_paid])
  end
end
