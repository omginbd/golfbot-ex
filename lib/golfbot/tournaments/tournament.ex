defmodule Golfbot.Tournaments.Tournament do
  use Ecto.Schema
  import Ecto.Changeset

  schema "tournaments" do
    field :date, :date
    field :name, :string

    timestamps()
  end

  @doc false
  def changeset(tournament, attrs) do
    tournament
    |> cast(attrs, [:name, :date])
    |> validate_required([:name, :date])
  end
end
