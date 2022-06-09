import Config
config :logger, level: :info

config :golfbot, GolfbotWeb.Endpoint,
  cache_static_manifest: "priv/static/cache_manifest.json",
  url: [host: "app.wiffleball.xyz", port: 80, schema: "https"]
