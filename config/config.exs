# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

# Configures the endpoint
config :storm, StormWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "OLe4g48Do9h+po6wINWBAq6WwmUv+tRjeGRa922T0NVTto2uGRtlufH8UB+0kHRP",
  render_errors: [view: StormWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Storm.PubSub,
  live_view: [signing_salt: "7Ak6snMe"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  level: :debug,
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
