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
    |> validate_format(:first_name, ~r/^[a-zA-Z]+$/,
      message: "First name must be one word with only letters"
    )
    |> validate_format(:last_name, ~r/^[a-zA-Z]+$/,
      message: "Last name must be one word with only letters"
    )
    |> update_change(:first_name, &String.capitalize/1)
    |> update_change(:last_name, &String.capitalize/1)
    |> unique_constraint(:unique_name, name: :unique_name)
  end

  def empty_changeset(), do: %__MODULE__{} |> cast(%{}, [])
end
