defmodule Golfbot.Scores.Score do
  use Ecto.Schema
  import Ecto.Changeset

  schema "scores" do
    field :hole_num, :integer
    field :round_num, :integer
    field :value, :integer
    field :registration_id, :id

    timestamps()
  end

  @doc false
  def changeset(score, attrs) do
    score
    |> cast(attrs, [:hole_num, :round_num, :value])
    |> validate_required([:hole_num, :round_num, :value])
  end
end
