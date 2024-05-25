defmodule Apollo.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      ApolloWeb.Telemetry,
      Apollo.Repo,
      {DNSCluster, query: Application.get_env(:apollo, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Apollo.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Apollo.Finch},
      # Start a worker by calling: Apollo.Worker.start_link(arg)
      # {Apollo.Worker, arg},
      # Start to serve requests, typically the last entry
      ApolloWeb.Endpoint,
      Apollo.Gemini.Cache
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Apollo.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    ApolloWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
