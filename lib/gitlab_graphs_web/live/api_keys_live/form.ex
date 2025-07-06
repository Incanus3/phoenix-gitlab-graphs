defmodule GitlabGraphsWeb.ApiKeysLive.Form do
  alias GitlabGraphs.Gitlab.ApiKey
  alias GitlabGraphs.Gitlab
  use GitlabGraphsWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        {@page_title}
        <:subtitle>Use this form to manage api key records in your database.</:subtitle>
      </.header>

      <.form for={@form} id="api-key-form" phx-change="validate" phx-submit="save">
        <.input field={@form[:name]} type="text" label="Name" />
        <.input field={@form[:key]} type="text" label="Key" />
        <footer>
          <.button phx-disable-with="Saving..." variant="primary">Save Api Key</.button>
          <.button navigate={return_path(@current_scope, @return_to, @api_key)}>Cancel</.button>
        </footer>
      </.form>
    </Layouts.app>
    """
  end

  @impl true
  def mount(params, _session, socket) do
    {:ok,
     socket
     |> assign(:return_to, return_to(params["return_to"]))
     |> apply_action(socket.assigns.live_action, params)}
  end

  defp return_to("show"), do: "show"
  defp return_to(_), do: "index"

  defp return_path(_scope, "index", _api_key), do: ~p"/api_keys"
  defp return_path(_scope, "show", api_key), do: ~p"/api_keys/#{api_key}"

  defp apply_action(socket, :edit, %{"id" => id}) do
    key = Gitlab.get_api_key!(socket.assigns.current_scope, id)

    socket
    |> assign(:page_title, "Edit Api Key")
    |> assign(:api_key, key)
    |> assign(:form, to_form(Gitlab.change_api_key(socket.assigns.current_scope, key)))
  end

  defp apply_action(socket, :new, _params) do
    key = %ApiKey{user_id: socket.assigns.current_scope.user.id}

    socket
    |> assign(:page_title, "New Api Key")
    |> assign(:api_key, key)
    |> assign(:form, to_form(Gitlab.change_api_key(socket.assigns.current_scope, key)))
  end

  @impl true
  def handle_event("validate", %{"api_key" => params}, socket) do
    changeset =
      Gitlab.change_api_key(socket.assigns.current_scope, socket.assigns.api_key, params)

    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"api_key" => params}, socket) do
    save_api_key(socket, socket.assigns.live_action, params)
  end

  defp save_api_key(socket, :edit, params) do
    case Gitlab.update_api_key(
           socket.assigns.current_scope,
           socket.assigns.api_key,
           params
         ) do
      {:ok, api_key} ->
        {:noreply,
         socket
         |> put_flash(:info, "Api key updated successfully")
         |> push_navigate(
           to: return_path(socket.assigns.current_scope, socket.assigns.return_to, api_key)
         )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_api_key(socket, :new, params) do
    case Gitlab.create_api_key(socket.assigns.current_scope, params) do
      {:ok, api_key} ->
        {:noreply,
         socket
         |> put_flash(:info, "Api key created successfully")
         |> push_navigate(
           to: return_path(socket.assigns.current_scope, socket.assigns.return_to, api_key)
         )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end
end
