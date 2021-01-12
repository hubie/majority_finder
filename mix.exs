defmodule MajorityFinder.MixProject do
  use Mix.Project

  def project do
    [
      app: :majority_finder,
      version: "0.1.0",
      elixir: "~> 1.7",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {MajorityFinder.Application, []},
      extra_applications: [:logger, :runtime_tools, :elixir_google_spreadsheets]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:phoenix, "~> 1.5.7"},
      {:phoenix_live_view, "~> 0.15.3"},
      {:floki, ">= 0.0.0", only: :test},
      {:phoenix_html, "~> 2.11"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:phoenix_live_dashboard, "~> 0.4"},
      {:telemetry_metrics, "~> 0.5"},
      {:telemetry_poller, "~> 0.5"},
      {:gettext, "~> 0.11"},
      {:jason, "~> 1.2"},
      {:plug_cowboy, "~> 2.0"},
      {:elixir_uuid, "~> 1.2"},
      {:bodyguard, "~> 2.4"},
      {:cors_plug, "~> 2.0"},
      {:plug_canonical_host, "~> 2.0"},
      {:elixir_google_spreadsheets, "~> 0.1.17"}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to install project dependencies and perform other setup tasks, run:
  #
  #     $ mix setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      test: ["test"]
    ]
  end
end
