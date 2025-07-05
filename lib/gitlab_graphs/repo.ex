defmodule GitlabGraphs.Repo do
  use Ecto.Repo,
    otp_app: :gitlab_graphs,
    adapter: Ecto.Adapters.Postgres
end
