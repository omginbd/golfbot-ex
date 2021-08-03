defmodule Golfbot.Tournaments.Tournament do
  use Ecto.Schema
  import Ecto.Changeset
  alias Golfbot.Accounts.User
  alias Golfbot.Tournaments

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
    |> foreign_key_constraint(:registration_id)
  end

  def register_user(%__MODULE__{id: tournament_id}, %User{} = user) do
    Tournaments.create_registration(%{
      tournament_id: tournament_id,
      user_id: user.id
    })
    |> case do
      {:ok, _registration} -> {:ok, user}
      _ -> {:err, user}
    end
  end
end
