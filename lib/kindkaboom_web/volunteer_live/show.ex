defmodule KindkaboomWeb.VolunteerLive.Show do
  use KindkaboomWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <.header>
      Volunteer {@volunteer.id}
      <:subtitle>This is a volunteer record from your database.</:subtitle>

      <:actions>
        <.link patch={~p"/volunteers/#{@volunteer}/show/edit"} phx-click={JS.push_focus()}>
          <.button>Edit volunteer</.button>
        </.link>
      </:actions>
    </.header>

    <.list>
      <:item title="Id">{@volunteer.id}</:item>

      <:item title="Name">{@volunteer.name}</:item>

      <:item title="Volunteer interests">{@volunteer.volunteer_interests}</:item>
    </.list>

    <.back navigate={~p"/volunteers"}>Back to volunteers</.back>

    <.modal
      :if={@live_action == :edit}
      id="volunteer-modal"
      show
      on_cancel={JS.patch(~p"/volunteers/#{@volunteer}")}
    >
      <.live_component
        module={KindkaboomWeb.VolunteerLive.FormComponent}
        id={@volunteer.id}
        title={@page_title}
        action={@live_action}
        current_user={@current_user}
        volunteer={@volunteer}
        patch={~p"/volunteers/#{@volunteer}"}
      />
    </.modal>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(
       :volunteer,
       Ash.get!(Kindkaboom.Organizations.Volunteer, id, actor: socket.assigns.current_user)
     )}
  end

  defp page_title(:show), do: "Show Volunteer"
  defp page_title(:edit), do: "Edit Volunteer"
end
