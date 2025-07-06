defmodule GitlabGraphsWeb.ApiKeysLive.Show do
  use GitlabGraphsWeb, :live_view

  alias GitlabGraphs.Gitlab

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Api key {@api_key.id}
        <:subtitle>This is a api key record from your database.</:subtitle>
        <:actions>
          <.button navigate={~p"/api_keys"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button variant="primary" navigate={~p"/api_keys/#{@api_key}/edit?return_to=show"}>
            <.icon name="hero-pencil-square" /> Edit api key
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title="Name">{@api_key.name}</:item>
        <:item title="Key">{@api_key.key}</:item>
      </.list>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    # if connected?(socket) do
    #   Test.subscribe_resources(socket.assigns.current_scope)
    # end

    {:ok,
     socket
     |> assign(:page_title, "Show Api Key")
     |> assign(:api_key, Gitlab.get_api_key!(socket.assigns.current_scope, id))}
  end
end
