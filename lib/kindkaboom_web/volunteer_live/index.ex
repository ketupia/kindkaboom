defmodule KindkaboomWeb.VolunteerLive.Index do
  use KindkaboomWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <.header>
      Listing Volunteers
      <:actions>
        <.link patch={~p"/volunteers/new"}>
          <.button>New Volunteer</.button>
        </.link>
      </:actions>
    </.header>

    <.table
      id="volunteers"
      rows={@streams.volunteers}
      row_click={fn {_id, volunteer} -> JS.navigate(~p"/volunteers/#{volunteer}") end}
    >
      <:col :let={{_id, volunteer}} label="Id">{volunteer.id}</:col>

      <:col :let={{_id, volunteer}} label="Name">{volunteer.name}</:col>

      <:col :let={{_id, volunteer}} label="Volunteer interests">{volunteer.volunteer_interests}</:col>

      <:action :let={{_id, volunteer}}>
        <div class="sr-only">
          <.link navigate={~p"/volunteers/#{volunteer}"}>Show</.link>
        </div>

        <.link patch={~p"/volunteers/#{volunteer}/edit"}>Edit</.link>
      </:action>

      <:action :let={{id, volunteer}}>
        <.link
          phx-click={JS.push("delete", value: %{id: volunteer.id}) |> hide("##{id}")}
          data-confirm="Are you sure?"
        >
          Delete
        </.link>
      </:action>
    </.table>

    <.modal
      :if={@live_action in [:new, :edit]}
      id="volunteer-modal"
      show
      on_cancel={JS.patch(~p"/volunteers")}
    >
      <.live_component
        module={KindkaboomWeb.VolunteerLive.FormComponent}
        id={(@volunteer && @volunteer.id) || :new}
        title={@page_title}
        current_user={@current_user}
        action={@live_action}
        volunteer={@volunteer}
        patch={~p"/volunteers"}
      />
    </.modal>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> stream(
       :volunteers,
       Ash.read!(Kindkaboom.Organizations.Volunteer, actor: socket.assigns[:current_user])
     )
     |> assign_new(:current_user, fn -> nil end)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Volunteer")
    |> assign(
      :volunteer,
      Ash.get!(Kindkaboom.Organizations.Volunteer, id, actor: socket.assigns.current_user)
    )
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Volunteer")
    |> assign(:volunteer, nil)
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Volunteers")
    |> assign(:volunteer, nil)
  end

  @impl true
  def handle_info({KindkaboomWeb.VolunteerLive.FormComponent, {:saved, volunteer}}, socket) do
    {:noreply, stream_insert(socket, :volunteers, volunteer)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    volunteer =
      Ash.get!(Kindkaboom.Organizations.Volunteer, id, actor: socket.assigns.current_user)

    Ash.destroy!(volunteer, actor: socket.assigns.current_user)

    {:noreply, stream_delete(socket, :volunteers, volunteer)}
  end
end
