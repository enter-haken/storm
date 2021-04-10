use Mix.Config

config :storm, StormWeb.Endpoint,
  http: [port: 4000],
  debug_errors: true,
  code_reloader: true,
  check_origin: false,
  watchers: [
    node: [
      "node_modules/webpack/bin/webpack.js",
      "--mode",
      "development",
      "--watch-stdin",
      cd: Path.expand("../assets", __DIR__)
    ]
  ]

config :storm, StormWeb.Endpoint,
  live_reload: [
    patterns: [
      ~r"priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$",
      ~r"lib/storm_web/(live|views)/.*(ex)$",
      ~r"lib/storm_web/templates/.*(eex)$"
    ]
  ]

config :storm, :pg_config,
  hostname: "localhost",
  username: "postgres",
  password: "postgres",
  database: "storm_dev",
  pool_size: 10

config :logger, :console, format: "[$level] $message\n"
config :phoenix, :stacktrace_depth, 20
config :phoenix, :plug_init_mode, :runtime
