defmodule Dento.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      DentoWeb.Telemetry,
      Dento.Repo,
      {Ecto.Migrator,
        repos: Application.fetch_env!(:dento, :ecto_repos),
        skip: skip_migrations?()},
      {DNSCluster, query: Application.get_env(:dento, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Dento.PubSub},
      DentoWeb.Presence,
      # Start the Finch HTTP client for sending emails
      {Finch, name: Dento.Finch},
      # Start a worker by calling: Dento.Worker.start_link(arg)
      # {Dento.Worker, arg},
      # Start to serve requests, typically the last entry
      DentoWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Dento.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    DentoWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  defp skip_migrations?() do
    # By default, sqlite migrations are run when using a release
    System.get_env("RELEASE_NAME") != nil
  end
end
