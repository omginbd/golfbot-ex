defmodule Golfbot.Tournaments.Tournament do
  use Ecto.Schema
  import Ecto.Changeset

  schema "tournaments" do
    field :date, :date
    field :name, :string

    has_many :registrations, Golfbot.Tournaments.Registration

    timestamps()
  end

  @doc false
  def changeset(tournament, attrs) do
    tournament
    |> cast(attrs, [:name, :date])
    |> validate_required([:name, :date])
  end
end
