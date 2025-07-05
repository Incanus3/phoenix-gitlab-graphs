defmodule GitlabGraphsWeb.ResourceLive.Show do
  use GitlabGraphsWeb, :live_view

  alias GitlabGraphs.Test

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Resource {@resource.id}
        <:subtitle>This is a resource record from your database.</:subtitle>
        <:actions>
          <.button navigate={~p"/resources"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button variant="primary" navigate={~p"/resources/#{@resource}/edit?return_to=show"}>
            <.icon name="hero-pencil-square" /> Edit resource
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title="Name">{@resource.name}</:item>
        <:item title="Age">{@resource.age}</:item>
      </.list>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    if connected?(socket) do
      Test.subscribe_resources(socket.assigns.current_scope)
    end

    {:ok,
     socket
     |> assign(:page_title, "Show Resource")
     |> assign(:resource, Test.get_resource!(socket.assigns.current_scope, id))}
  end

  @impl true
  def handle_info(
        {:updated, %GitlabGraphs.Test.Resource{id: id} = resource},
        %{assigns: %{resource: %{id: id}}} = socket
      ) do
    {:noreply, assign(socket, :resource, resource)}
  end

  def handle_info(
        {:deleted, %GitlabGraphs.Test.Resource{id: id}},
        %{assigns: %{resource: %{id: id}}} = socket
      ) do
    {:noreply,
     socket
     |> put_flash(:error, "The current resource was deleted.")
     |> push_navigate(to: ~p"/resources")}
  end

  def handle_info({type, %GitlabGraphs.Test.Resource{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply, socket}
  end
end
