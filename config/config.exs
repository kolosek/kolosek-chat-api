# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :company_api,
  ecto_repos: [CompanyApi.Repo]

# Configures the endpoint
config :company_api, CompanyApiWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "Pi62cI4AnRW78RRkljOS1cio+z4Gcn27Z/dtIhdbNL0JOCV3DT3cZvgoWaPOTic1",
  render_errors: [view: CompanyApiWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: CompanyApi.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Configures Bamboo mailer
config :company_api, CompanyApi.Mailer,
  adapter: Bamboo.LocalAdapter

#Configure guardian
config :company_api, CompanyApi.Guardian,
  issuer: "CompanyApi",
  secret_key: "QDG1lCBdCdjwF49UniOpbxgUINhdyvQDcFQUQam+65O4f9DgWRe09BYMEEDU1i9X",
  verify_issuer: true

import_config "#{Mix.env}.exs"
