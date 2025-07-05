defmodule GitlabGraphsWeb.ResourceLive.Index do
  use GitlabGraphsWeb, :live_view

  alias GitlabGraphs.Test

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Listing Resources
        <:actions>
          <.button variant="primary" navigate={~p"/resources/new"}>
            <.icon name="hero-plus" /> New Resource
          </.button>
        </:actions>
      </.header>

      <.table
        id="resources"
        rows={@streams.resources}
        row_click={fn {_id, resource} -> JS.navigate(~p"/resources/#{resource}") end}
      >
        <:col :let={{_id, resource}} label="Name">{resource.name}</:col>
        <:col :let={{_id, resource}} label="Age">{resource.age}</:col>
        <:action :let={{_id, resource}}>
          <div class="sr-only">
            <.link navigate={~p"/resources/#{resource}"}>Show</.link>
          </div>
          <.link navigate={~p"/resources/#{resource}/edit"}>Edit</.link>
        </:action>
        <:action :let={{id, resource}}>
          <.link
            phx-click={JS.push("delete", value: %{id: resource.id}) |> hide("##{id}")}
            data-confirm="Are you sure?"
          >
            Delete
          </.link>
        </:action>
      </.table>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Test.subscribe_resources(socket.assigns.current_scope)
    end

    {:ok,
     socket
     |> assign(:page_title, "Listing Resources")
     |> stream(:resources, Test.list_resources(socket.assigns.current_scope))}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    resource = Test.get_resource!(socket.assigns.current_scope, id)
    {:ok, _} = Test.delete_resource(socket.assigns.current_scope, resource)

    {:noreply, stream_delete(socket, :resources, resource)}
  end

  @impl true
  def handle_info({type, %GitlabGraphs.Test.Resource{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply, stream(socket, :resources, Test.list_resources(socket.assigns.current_scope), reset: true)}
  end
end
