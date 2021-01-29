defmodule Golfbot.Repo do
  use Ecto.Repo,
    otp_app: :golfbot,
    adapter: Ecto.Adapters.Postgres
end
