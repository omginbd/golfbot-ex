defmodule Golfbot.Tournaments.Registration do
  use Ecto.Schema
  import Ecto.Changeset

  alias Golfbot.Scores.Score

  schema "registrations" do
    field :has_paid, :boolean, default: false
    field :tournament_id, :id

    belongs_to :user, Golfbot.Accounts.User
    has_many :scores, Score

    timestamps()
  end

  @doc false
  def changeset(registration, attrs) do
    registration
    |> cast(attrs, [:has_paid, :tournament_id, :user_id])
    |> validate_required([:has_paid, :tournament_id, :user_id])
  end
end
