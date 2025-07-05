defmodule GitlabGraphs.TestFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `GitlabGraphs.Test` context.
  """

  @doc """
  Generate a resource.
  """
  def resource_fixture(scope, attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        age: 42,
        name: "some name"
      })

    {:ok, resource} = GitlabGraphs.Test.create_resource(scope, attrs)
    resource
  end
end
