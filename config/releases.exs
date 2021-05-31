import Config

config :golfbot, Golfbot.Repo,
  pool_size: String.to_integer(System.fetch_env!("POOL_SIZE")),
  url: System.fetch_env!("DATABASE_URL")

config :golfbot, GolfbotWeb.Endpoint,
  server: true,
  http: [port: {:system, "PORT"}],
  url: [host: "app.wiffleball.xyz", port: 443]
