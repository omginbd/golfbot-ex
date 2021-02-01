import Config
config :logger, level: :info

config :golfbot, GolfbotWeb.Endpoint, force_ssl: [rewrite_on: [:x_forwarded_proto]]

config :ueberauth, Ueberauth.Strategy.Google.OAuth,
  client_id: System.fetch_env!("GOOGLE_OAUTH_CLIENT_ID"),
  client_secret: System.fetch_env!("GOOGLE_OAUTH_CLIENT_SECRET")
