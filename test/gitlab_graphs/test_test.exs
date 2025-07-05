defmodule GitlabGraphs.TestTest do
  use GitlabGraphs.DataCase

  alias GitlabGraphs.Test

  describe "resources" do
    alias GitlabGraphs.Test.Resource

    import GitlabGraphs.AccountsFixtures, only: [user_scope_fixture: 0]
    import GitlabGraphs.TestFixtures

    @invalid_attrs %{name: nil, age: nil}

    test "list_resources/1 returns all scoped resources" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      resource = resource_fixture(scope)
      other_resource = resource_fixture(other_scope)
      assert Test.list_resources(scope) == [resource]
      assert Test.list_resources(other_scope) == [other_resource]
    end

    test "get_resource!/2 returns the resource with given id" do
      scope = user_scope_fixture()
      resource = resource_fixture(scope)
      other_scope = user_scope_fixture()
      assert Test.get_resource!(scope, resource.id) == resource
      assert_raise Ecto.NoResultsError, fn -> Test.get_resource!(other_scope, resource.id) end
    end

    test "create_resource/2 with valid data creates a resource" do
      valid_attrs = %{name: "some name", age: 42}
      scope = user_scope_fixture()

      assert {:ok, %Resource{} = resource} = Test.create_resource(scope, valid_attrs)
      assert resource.name == "some name"
      assert resource.age == 42
      assert resource.user_id == scope.user.id
    end

    test "create_resource/2 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      assert {:error, %Ecto.Changeset{}} = Test.create_resource(scope, @invalid_attrs)
    end

    test "update_resource/3 with valid data updates the resource" do
      scope = user_scope_fixture()
      resource = resource_fixture(scope)
      update_attrs = %{name: "some updated name", age: 43}

      assert {:ok, %Resource{} = resource} = Test.update_resource(scope, resource, update_attrs)
      assert resource.name == "some updated name"
      assert resource.age == 43
    end

    test "update_resource/3 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      resource = resource_fixture(scope)

      assert_raise MatchError, fn ->
        Test.update_resource(other_scope, resource, %{})
      end
    end

    test "update_resource/3 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      resource = resource_fixture(scope)
      assert {:error, %Ecto.Changeset{}} = Test.update_resource(scope, resource, @invalid_attrs)
      assert resource == Test.get_resource!(scope, resource.id)
    end

    test "delete_resource/2 deletes the resource" do
      scope = user_scope_fixture()
      resource = resource_fixture(scope)
      assert {:ok, %Resource{}} = Test.delete_resource(scope, resource)
      assert_raise Ecto.NoResultsError, fn -> Test.get_resource!(scope, resource.id) end
    end

    test "delete_resource/2 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      resource = resource_fixture(scope)
      assert_raise MatchError, fn -> Test.delete_resource(other_scope, resource) end
    end

    test "change_resource/2 returns a resource changeset" do
      scope = user_scope_fixture()
      resource = resource_fixture(scope)
      assert %Ecto.Changeset{} = Test.change_resource(scope, resource)
    end
  end
end
