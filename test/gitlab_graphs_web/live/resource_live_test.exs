defmodule GitlabGraphsWeb.ResourceLiveTest do
  use GitlabGraphsWeb.ConnCase

  import Phoenix.LiveViewTest
  import GitlabGraphs.TestFixtures

  @create_attrs %{name: "some name", age: 42}
  @update_attrs %{name: "some updated name", age: 43}
  @invalid_attrs %{name: nil, age: nil}

  setup :register_and_log_in_user

  defp create_resource(%{scope: scope}) do
    resource = resource_fixture(scope)

    %{resource: resource}
  end

  describe "Index" do
    setup [:create_resource]

    test "lists all resources", %{conn: conn, resource: resource} do
      {:ok, _index_live, html} = live(conn, ~p"/resources")

      assert html =~ "Listing Resources"
      assert html =~ resource.name
    end

    test "saves new resource", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/resources")

      assert {:ok, form_live, _} =
               index_live
               |> element("a", "New Resource")
               |> render_click()
               |> follow_redirect(conn, ~p"/resources/new")

      assert render(form_live) =~ "New Resource"

      assert form_live
             |> form("#resource-form", resource: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#resource-form", resource: @create_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/resources")

      html = render(index_live)
      assert html =~ "Resource created successfully"
      assert html =~ "some name"
    end

    test "updates resource in listing", %{conn: conn, resource: resource} do
      {:ok, index_live, _html} = live(conn, ~p"/resources")

      assert {:ok, form_live, _html} =
               index_live
               |> element("#resources-#{resource.id} a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/resources/#{resource}/edit")

      assert render(form_live) =~ "Edit Resource"

      assert form_live
             |> form("#resource-form", resource: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#resource-form", resource: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/resources")

      html = render(index_live)
      assert html =~ "Resource updated successfully"
      assert html =~ "some updated name"
    end

    test "deletes resource in listing", %{conn: conn, resource: resource} do
      {:ok, index_live, _html} = live(conn, ~p"/resources")

      assert index_live |> element("#resources-#{resource.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#resources-#{resource.id}")
    end
  end

  describe "Show" do
    setup [:create_resource]

    test "displays resource", %{conn: conn, resource: resource} do
      {:ok, _show_live, html} = live(conn, ~p"/resources/#{resource}")

      assert html =~ "Show Resource"
      assert html =~ resource.name
    end

    test "updates resource and returns to show", %{conn: conn, resource: resource} do
      {:ok, show_live, _html} = live(conn, ~p"/resources/#{resource}")

      assert {:ok, form_live, _} =
               show_live
               |> element("a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/resources/#{resource}/edit?return_to=show")

      assert render(form_live) =~ "Edit Resource"

      assert form_live
             |> form("#resource-form", resource: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, show_live, _html} =
               form_live
               |> form("#resource-form", resource: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/resources/#{resource}")

      html = render(show_live)
      assert html =~ "Resource updated successfully"
      assert html =~ "some updated name"
    end
  end
end
