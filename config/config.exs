# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# Configures the endpoint
config :exagg, Exagg.Endpoint,
  url: [host: "localhost"],
  root: Path.dirname(__DIR__),
  secret_key_base: "2wTBVJ7pHDptyEVkt7aaUAUetsKzOWYO2mNsSG8tin1vNjnWEXKiH95FceiVtgG7",
  render_errors: [accepts: ~w(html json)],
  pubsub: [name: Exagg.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"

# Configure phoenix generators
config :phoenix, :generators,
  migration: true,
  binary_id: false

# Add support for JSON-API mimetype
config :plug, :mimes, %{
  "application/vnd.api+json" => ["json-api"]
}

# Quantum scheduled tasks
config :quantum, cron: [
  sync: [
    schedule: "*/30 * * * *",
    task: {Exagg.Syncer, :sync_all},
    overlap: false
  ]
]
