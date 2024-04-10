defmodule House.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      HouseWeb.Telemetry,
      House.Repo,
      {DNSCluster, query: Application.get_env(:house, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: House.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: House.Finch},
      # Start a worker by calling: House.Worker.start_link(arg)
      # {House.Worker, arg},
      # Start to serve requests, typically the last entry
      HouseWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: House.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    HouseWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
