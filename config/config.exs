# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :golfbot,
  ecto_repos: [Golfbot.Repo]

# Configures the endpoint
config :golfbot, GolfbotWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "UmDa7xquFoAZEglMh2zGZ9AF5eHiEzGh17Urvr3o2sLE8Zi3KAnjPdO0x2+8asdk",
  render_errors: [view: GolfbotWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Golfbot.PubSub,
  live_view: [signing_salt: "ubpcd+z8"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
