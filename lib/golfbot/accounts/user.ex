defmodule Golfbot.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  alias Golfbot.Tournaments.Registration

  @derive {Inspect, except: [:password]}
  schema "users" do
    field :first_name, :string
    field :last_name, :string

    has_many :registrations, Registration

    timestamps()
  end

  def changeset(user, attrs) do
    user
    |> cast(attrs, [:first_name, :last_name])
    |> validate_required([:first_name, :last_name])
    |> unique_constraint(:unique_name, name: :unique_name)
  end
end
