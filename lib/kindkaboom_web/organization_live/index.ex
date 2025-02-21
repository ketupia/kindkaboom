defmodule KindkaboomWeb.OrganizationLive.Index do
  use KindkaboomWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <.header>
      Listing Organizations
      <:actions>
        <.link patch={~p"/organizations/new"}>
          <.button>New Organization</.button>
        </.link>
      </:actions>
    </.header>

    <.table
      id="organizations"
      rows={@streams.organizations}
      row_click={fn {_id, organization} -> JS.navigate(~p"/organizations/#{organization}") end}
    >
      <:col :let={{_id, organization}} label="Id">{organization.id}</:col>

      <:col :let={{_id, organization}} label="Name">{organization.name}</:col>

      <:col :let={{_id, organization}} label="Description">{organization.description}</:col>

      <:col :let={{_id, organization}} label="Logo url">{organization.logo_url}</:col>

      <:col :let={{_id, organization}} label="Website">{organization.website}</:col>

      <:action :let={{_id, organization}}>
        <div class="sr-only">
          <.link navigate={~p"/organizations/#{organization}"}>Show</.link>
        </div>

        <.link patch={~p"/organizations/#{organization}/edit"}>Edit</.link>
      </:action>

      <:action :let={{id, organization}}>
        <.link
          phx-click={JS.push("delete", value: %{id: organization.id}) |> hide("##{id}")}
          data-confirm="Are you sure?"
        >
          Delete
        </.link>
      </:action>
    </.table>

    <.modal
      :if={@live_action in [:new, :edit]}
      id="organization-modal"
      show
      on_cancel={JS.patch(~p"/organizations")}
    >
      <.live_component
        module={KindkaboomWeb.OrganizationLive.FormComponent}
        id={(@organization && @organization.id) || :new}
        title={@page_title}
        current_user={@current_user}
        action={@live_action}
        organization={@organization}
        patch={~p"/organizations"}
      />
    </.modal>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> stream(
       :organizations,
       Ash.read!(Kindkaboom.Organizations.Organization, actor: socket.assigns[:current_user])
     )
     |> assign_new(:current_user, fn -> nil end)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Organization")
    |> assign(
      :organization,
      Ash.get!(Kindkaboom.Organizations.Organization, id, actor: socket.assigns.current_user)
    )
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Organization")
    |> assign(:organization, nil)
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Organizations")
    |> assign(:organization, nil)
  end

  @impl true
  def handle_info({KindkaboomWeb.OrganizationLive.FormComponent, {:saved, organization}}, socket) do
    {:noreply, stream_insert(socket, :organizations, organization)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    organization =
      Ash.get!(Kindkaboom.Organizations.Organization, id, actor: socket.assigns.current_user)

    Ash.destroy!(organization, actor: socket.assigns.current_user)

    {:noreply, stream_delete(socket, :organizations, organization)}
  end
end
