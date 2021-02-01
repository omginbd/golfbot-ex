import Config

config :golfbot, Golfbot.Repo,
  pool_size: String.to_integer(System.fetch_env!("POOL_SIZE")),
  url: System.fetch_env!("DATABASE_URL")

config :golfbot, GolfbotWeb.Endpoint,
  force_ssl: [rewrite_on: [:x_forwarded_proto]],
  server: true,
  http: [port: {:system, "PORT"}],
  url: [host: "2021.wiffleball.xyz", port: 443]
