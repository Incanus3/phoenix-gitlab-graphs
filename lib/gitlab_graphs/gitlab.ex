defmodule GitlabGraphs.Gitlab do
  import Ecto.Query, warn: false

  alias GitlabGraphs.Repo
  alias GitlabGraphs.Accounts.Scope
  alias GitlabGraphs.Gitlab.ApiKey

  def list_api_keys(%Scope{} = scope) do
    Repo.all(from api_key in ApiKey, where: api_key.user_id == ^scope.user.id)
  end

  def get_api_key!(%Scope{} = scope, id) do
    Repo.get_by!(ApiKey, id: id, user_id: scope.user.id)
  end

  def change_api_key(%Scope{} = scope, %ApiKey{} = api_key, attrs \\ %{}) do
    true = api_key.user_id == scope.user.id

    ApiKey.changeset(api_key, attrs, scope)
  end

  def create_api_key(%Scope{} = scope, attrs) do
    with {:ok, api_key = %ApiKey{}} <-
           %ApiKey{}
           |> ApiKey.changeset(attrs, scope)
           |> Repo.insert() do
      # broadcast(scope, {:created, api_key})
      {:ok, api_key}
    end
  end

  def update_api_key(%Scope{} = scope, %ApiKey{} = api_key, attrs) do
    true = api_key.user_id == scope.user.id

    with {:ok, api_key = %ApiKey{}} <-
           api_key
           |> ApiKey.changeset(attrs, scope)
           |> Repo.update() do
      # broadcast(scope, {:updated, api_key})
      {:ok, api_key}
    end
  end

  def delete_api_key(%Scope{} = scope, %ApiKey{} = api_key) do
    true = api_key.user_id == scope.user.id

    with {:ok, api_key = %ApiKey{}} <-
           Repo.delete(api_key) do
      # broadcast(scope, {:deleted, api_key})
      {:ok, api_key}
    end
  end
end
