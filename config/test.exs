import Config
config :kindkaboom, Oban, testing: :manual
config :kindkaboom, token_signing_secret: "y2yI3hl7kZHyDuYOoZq918b6hbye09W/"
config :ash, disable_async?: true

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :kindkaboom, Kindkaboom.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "kindkaboom_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: System.schedulers_online() * 2

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :kindkaboom, KindkaboomWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "c7EpSadFBagDL9xrdgUt/KV7q8MK/WyTZ7rCN2WIxVHAF4oOcAoyyKkDi4dgGobQ",
  server: false

# In test we don't send emails
config :kindkaboom, Kindkaboom.Mailer, adapter: Swoosh.Adapters.Test

# Disable swoosh api client as it is only required for production adapters
config :swoosh, :api_client, false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

# Enable helpful, but potentially expensive runtime checks
config :phoenix_live_view,
  enable_expensive_runtime_checks: true

if System.get_env("GITHUB_ACTIONS") do
  config :kindkaboom, Kindkaboom.Repo,
    username: "postgres",
    password: "postgres"
end
