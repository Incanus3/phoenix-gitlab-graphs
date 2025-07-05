defmodule GitlabGraphs.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      GitlabGraphsWeb.Telemetry,
      GitlabGraphs.Repo,
      {DNSCluster, query: Application.get_env(:gitlab_graphs, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: GitlabGraphs.PubSub},
      # Start a worker by calling: GitlabGraphs.Worker.start_link(arg)
      # {GitlabGraphs.Worker, arg},
      # Start to serve requests, typically the last entry
      GitlabGraphsWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: GitlabGraphs.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    GitlabGraphsWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
