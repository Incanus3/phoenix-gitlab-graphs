defmodule GitlabGraphsWeb.ApiKeysLive.Index do
  use GitlabGraphsWeb, :live_view

  alias GitlabGraphs.Gitlab

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.flash_group flash={@flash} />

    <.header>
      Listing Api Keys
      <:actions>
        <.button variant="primary" navigate={~p"/api_keys/new"}>
          <.icon name="hero-plus" /> New Api Key
        </.button>
      </:actions>
    </.header>

    <.table
      id="api_keys"
      rows={@streams.api_keys}
      row_click={fn {_id, api_key} -> JS.navigate(~p"/api_keys/#{api_key}") end}
    >
      <:col :let={{_id, api_key}} label="Name">{api_key.name}</:col>
      <:col :let={{_id, api_key}} label="Key">{api_key.key}</:col>
      <:action :let={{_id, api_key}}>
        <div class="sr-only">
          <.link navigate={~p"/api_keys/#{api_key}"}>Show</.link>
        </div>
        <.link navigate={~p"/api_keys/#{api_key}/edit"}>Edit</.link>
      </:action>
      <:action :let={{id, api_key}}>
        <.link
          phx-click={JS.push("delete", value: %{id: api_key.id}) |> hide("##{id}")}
          data-confirm="Are you sure?"
        >
          Delete
        </.link>
      </:action>
    </.table>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Listing Api Keys")
     |> stream(:api_keys, Gitlab.list_api_keys(socket.assigns.current_scope))}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    key = Gitlab.get_api_key!(socket.assigns.current_scope, id)
    {:ok, _} = Gitlab.delete_api_key(socket.assigns.current_scope, key)

    {:noreply, stream_delete(socket, :api_keys, key)}
  end
end
