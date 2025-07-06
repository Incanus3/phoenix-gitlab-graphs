defmodule GitlabGraphsWeb.GraphsLive.Show do
  use GitlabGraphsWeb, :live_view

  alias GitlabGraphs.Gitlab

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.flash_group flash={@flash} />

    <.header>
      Graph of {@live_action}
    </.header>

    <.form for={@form} phx-change="set-params" phx-submit="render">
      <.input
        field={@form[:key]}
        type="select"
        prompt="Select an API key"
        options={options_for(@keys)}
      />

      <.button phx-disable-with="Rendering..." variant="primary" disabled={@key == nil}>
        Render Graph
      </.button>
    </.form>

    <div :if={@graph} class="mt-2">
      <h2>Graph data:</h2>
      <pre><%= inspect(@graph) %></pre>
    </div>
    """
  end

  @impl true
  def mount(%{}, _session, socket) do
    {
      :ok,
      socket
      |> assign(:page_title, "Graphs")
      |> assign(:key, nil)
      |> assign(:graph, nil)
      |> assign(:form, to_form(%{"key" => nil}))
      |> assign(:keys, Gitlab.list_api_keys(socket.assigns.current_scope))
    }
  end

  @impl true
  def handle_event("set-params", %{"key" => key_id} = params, socket) do
    form = to_form(params)
    key_id = (key_id && key_id != "" && key_id) || nil
    key = key_id && Gitlab.get_api_key!(socket.assigns.current_scope, key_id)

    {:noreply, socket |> assign(:form, form) |> assign(:key, key)}
  end

  @impl true
  def handle_event("render", %{"key" => key_id}, socket) do
    key = Gitlab.get_api_key!(socket.assigns.current_scope, key_id)

    {:noreply, assign(socket, :graph, graph_for(key))}
  end

  defp options_for(keys) do
    Enum.map(keys, &{"#{&1.name} (#{&1.server})", &1.id})
  end

  defp graph_for(key) do
    {:ok, graph_data} = Gitlab.get_graph_data(key)
    graph_data
  end
end
