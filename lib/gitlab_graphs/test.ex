defmodule GitlabGraphs.Test do
  @moduledoc """
  The Test context.
  """

  import Ecto.Query, warn: false
  alias GitlabGraphs.Repo

  alias GitlabGraphs.Test.Resource
  alias GitlabGraphs.Accounts.Scope

  @doc """
  Subscribes to scoped notifications about any resource changes.

  The broadcasted messages match the pattern:

    * {:created, %Resource{}}
    * {:updated, %Resource{}}
    * {:deleted, %Resource{}}

  """
  def subscribe_resources(%Scope{} = scope) do
    key = scope.user.id

    Phoenix.PubSub.subscribe(GitlabGraphs.PubSub, "user:#{key}:resources")
  end

  defp broadcast(%Scope{} = scope, message) do
    key = scope.user.id

    Phoenix.PubSub.broadcast(GitlabGraphs.PubSub, "user:#{key}:resources", message)
  end

  @doc """
  Returns the list of resources.

  ## Examples

      iex> list_resources(scope)
      [%Resource{}, ...]

  """
  def list_resources(%Scope{} = scope) do
    Repo.all(from resource in Resource, where: resource.user_id == ^scope.user.id)
  end

  @doc """
  Gets a single resource.

  Raises `Ecto.NoResultsError` if the Resource does not exist.

  ## Examples

      iex> get_resource!(123)
      %Resource{}

      iex> get_resource!(456)
      ** (Ecto.NoResultsError)

  """
  def get_resource!(%Scope{} = scope, id) do
    Repo.get_by!(Resource, id: id, user_id: scope.user.id)
  end

  @doc """
  Creates a resource.

  ## Examples

      iex> create_resource(%{field: value})
      {:ok, %Resource{}}

      iex> create_resource(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_resource(%Scope{} = scope, attrs) do
    with {:ok, resource = %Resource{}} <-
           %Resource{}
           |> Resource.changeset(attrs, scope)
           |> Repo.insert() do
      broadcast(scope, {:created, resource})
      {:ok, resource}
    end
  end

  @doc """
  Updates a resource.

  ## Examples

      iex> update_resource(resource, %{field: new_value})
      {:ok, %Resource{}}

      iex> update_resource(resource, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_resource(%Scope{} = scope, %Resource{} = resource, attrs) do
    true = resource.user_id == scope.user.id

    with {:ok, resource = %Resource{}} <-
           resource
           |> Resource.changeset(attrs, scope)
           |> Repo.update() do
      broadcast(scope, {:updated, resource})
      {:ok, resource}
    end
  end

  @doc """
  Deletes a resource.

  ## Examples

      iex> delete_resource(resource)
      {:ok, %Resource{}}

      iex> delete_resource(resource)
      {:error, %Ecto.Changeset{}}

  """
  def delete_resource(%Scope{} = scope, %Resource{} = resource) do
    true = resource.user_id == scope.user.id

    with {:ok, resource = %Resource{}} <-
           Repo.delete(resource) do
      broadcast(scope, {:deleted, resource})
      {:ok, resource}
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking resource changes.

  ## Examples

      iex> change_resource(resource)
      %Ecto.Changeset{data: %Resource{}}

  """
  def change_resource(%Scope{} = scope, %Resource{} = resource, attrs \\ %{}) do
    true = resource.user_id == scope.user.id

    Resource.changeset(resource, attrs, scope)
  end
end
