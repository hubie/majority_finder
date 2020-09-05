defmodule MajorityFinder.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      MajorityFinderWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: MajorityFinder.PubSub},
      # Start the Endpoint (http/https)
      MajorityFinderWeb.Endpoint,
      # Start a worker by calling: MajorityFinder.Worker.start_link(arg)
      MajorityFinder.Presence,
      {MajorityFinder.Results, [name: MajorityFinder.Results]},
      {MajorityFinder.Metrics, [name: MajorityFinder.Metrics]}
    ]

    :ets.new(:auth_table, [:set, :public, :named_table, read_concurrency: true])
    :ets.new(:voter_state, [:set, :public, :named_table, read_concurrency: true])

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: MajorityFinder.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    MajorityFinderWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
