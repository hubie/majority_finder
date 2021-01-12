# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

# Configures the endpoint
config :majority_finder, MajorityFinderWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: System.get_env("SECRET_KEY_BASE"),
  render_errors: [view: MajorityFinderWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: MajorityFinder.PubSub,
  live_view: [signing_salt: System.get_env("LIVEVIEW_SIGNING_SALT")],
  default_embedded_vote_mode: :vote

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"

config :goth, json: System.get_env("GOOGLE_SERVICE_KEY")

config :elixir_google_spreadsheets, :client,
  request_workers: 20