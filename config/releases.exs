import Config

config :storm, :pg_config,
  hostname:
    System.get_env("POSTGRES_HOST") ||
      raise("POSTGRES_HOST not found (hint: export $(xargs < .env)"),
  username:
    System.get_env("POSTGRES_USER") ||
      raise("POSTGRES_USER not found (hint: export $(xargs < .env)"),
  password:
    System.get_env("POSTGRES_PASSWORD") ||
      raise("POSTGRES_PASSWORD not found (hint: export $(xargs < .env)"),
  database:
    System.get_env("POSTGRES_DB") ||
      raise("POSTGRES_DB not found (hint: export $(xargs < .env)"),
  pool_size: 10
