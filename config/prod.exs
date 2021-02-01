import Config
config :logger, level: :info

config :ueberauth, Ueberauth.Strategy.Google.OAuth,
  client_id: System.fetch_env!("GOOGLE_OAUTH_CLIENT_ID"),
  client_secret: System.fetch_env!("GOOGLE_OAUTH_CLIENT_SECRET")
