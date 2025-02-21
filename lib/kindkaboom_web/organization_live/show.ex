defmodule KindkaboomWeb.OrganizationLive.Show do
  use KindkaboomWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <.header>
      Organization {@organization.id}
      <:subtitle>This is a organization record from your database.</:subtitle>

      <:actions>
        <.link patch={~p"/organizations/#{@organization}/show/edit"} phx-click={JS.push_focus()}>
          <.button>Edit organization</.button>
        </.link>
      </:actions>
    </.header>

    <.list>
      <:item title="Id">{@organization.id}</:item>

      <:item title="Name">{@organization.name}</:item>

      <:item title="Description">{@organization.description}</:item>

      <:item title="Logo url">{@organization.logo_url}</:item>

      <:item title="Website">{@organization.website}</:item>
    </.list>

    <.back navigate={~p"/organizations"}>Back to organizations</.back>

    <.modal
      :if={@live_action == :edit}
      id="organization-modal"
      show
      on_cancel={JS.patch(~p"/organizations/#{@organization}")}
    >
      <.live_component
        module={KindkaboomWeb.OrganizationLive.FormComponent}
        id={@organization.id}
        title={@page_title}
        action={@live_action}
        current_user={@current_user}
        organization={@organization}
        patch={~p"/organizations/#{@organization}"}
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
       :organization,
       Ash.get!(Kindkaboom.Organizations.Organization, id, actor: socket.assigns.current_user)
     )}
  end

  defp page_title(:show), do: "Show Organization"
  defp page_title(:edit), do: "Edit Organization"
end
