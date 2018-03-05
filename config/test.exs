use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :company_api, CompanyApiWeb.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

#Configure bamboo test adapter
config :company_api, CompanyApi.Mailer,
  adapter: Bamboo.TestAdapter

# Configure your database
config :company_api, CompanyApi.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "developer",
  password: "developer",
  database: "company_api_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

  #Configure Guardian
config :company_api, CompanyApi.Guardian,
  issuer: "CompanyApi",
  secret_key: "Ti7yf41PQCNyTHTlOL8s2HJgmq/Z1OlsfRi7yK71oZwVgLi51+Bi9pDLohg8CWa"

