use Mix.Config

config :storm, StormWeb.Endpoint,
  cache_static_manifest: "priv/static/cache_manifest.json",
  http: [
    port: 4000,
    transport_options: [socket_opts: [:inet6]]
  ],
  secret_key_base: 64 |> :crypto.strong_rand_bytes() |> Base.encode64() |> binary_part(0,64),
  server: true,
  debug_errors: false,
  code_reloader: false,
  check_origin: false

config :logger, level: :info

# HINT: database connection information can be found in the `releases.exs`
# these information are evaluated at runtime.
