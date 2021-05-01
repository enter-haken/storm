import Config

config :storm, :pg_config,
  hostname:
    System.get_env("POSTGRES_HOST") ||
      raise("POSTGRES_HOST not found"),
  username:
    System.get_env("POSTGRES_USER") ||
      raise("POSTGRES_USER not found"),
  password:
    System.get_env("POSTGRES_PASSWORD") ||
      raise("POSTGRES_PASSWORD not found"),
  database:
    System.get_env("POSTGRES_DB") ||
      raise("POSTGRES_DB not found"),
  pool_size: 10
