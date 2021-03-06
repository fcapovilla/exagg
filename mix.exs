defmodule Exagg.Mixfile do
  use Mix.Project

  def project do
    [app: :exagg,
     version: "0.0.1",
     elixir: "~> 1.0",
     elixirc_paths: elixirc_paths(Mix.env),
     compilers: [:phoenix] ++ Mix.compilers,
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     aliases: aliases,
     deps: deps]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Exagg, []},
      applications: [
        :phoenix,
        :phoenix_pubsub,
        :phoenix_html,
        :cowboy,
        :logger,
        :gettext,
        :phoenix_ecto,
        :postgrex,
        :tzdata,
        :pipe,
        :quantum,
        :httpotion,
        :inflex,
        :paratize,
        :feeder_ex,
        :feeder,
        :comeonin,
        :joken,
        :ibrowse,
        :xmerl,
        :timex,
      ]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "web", "test/support"]
  defp elixirc_paths(_),     do: ["lib", "web"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:poison, "~> 2.0"},
      {:phoenix, "~> 1.2"},
      {:phoenix_pubsub, "~> 1.0"},
      {:phoenix_ecto, "~> 3.0"},
      {:postgrex, ">= 0.0.0"},
      {:feeder_ex, ">= 0.0.0"},
      {:httpotion, "~> 3.0"},
      {:timex, "~> 2.2"},
      {:pipe, ">= 0.0.0"},
      {:paratize, "~> 2.1"},
      {:quantum, "~> 1.7"},
      {:phoenix_html, "~> 2.6"},
      {:inflex, "~> 1.0"},
      {:comeonin, "~> 1.0"},
      {:joken, "~> 1.2"},
      {:phoenix_live_reload, "~> 1.0", only: :dev},
      {:credo, "~> 0.4", only: :dev},
      {:cowboy, "~> 1.0"},
      {:exrm, "~> 1.0"},
    ]
  end

  # Aliases are shortcut or tasks specific to the current project.
  # For example, to create, migrate and run the seeds file at once:
  #
  #     $ mix ecto.setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    ["ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
     "ecto.reset": ["ecto.drop", "ecto.setup"]]
  end
end
