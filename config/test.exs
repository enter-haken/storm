use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :storm, StormWeb.Endpoint,
  http: [port: 4002],
  server: false

# Print only warnings and errors during test

config :logger, :console, format: "[$level] $message\n"

config :storm, :pg_config,
  hostname: "localhost",
  username: "postgres",
  database: "storm_test",
  port: "5432",
  show_sensitive_data_on_connection_error: true
