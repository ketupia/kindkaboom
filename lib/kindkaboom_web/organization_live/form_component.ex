defmodule KindkaboomWeb.OrganizationLive.FormComponent do
  use KindkaboomWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        {@title}
        <:subtitle>Use this form to manage organization records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="organization-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:name]} type="text" label="Name" /><.input
          field={@form[:description]}
          type="text"
          label="Description"
        /><.input field={@form[:logo_url]} type="text" label="Logo url" /><.input
          field={@form[:website]}
          type="text"
          label="Website"
        />

        <:actions>
          <.button phx-disable-with="Saving...">Save Organization</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_form()}
  end

  @impl true
  def handle_event("validate", %{"organization" => organization_params}, socket) do
    {:noreply,
     assign(socket, form: AshPhoenix.Form.validate(socket.assigns.form, organization_params))}
  end

  def handle_event("save", %{"organization" => organization_params}, socket) do
    case AshPhoenix.Form.submit(socket.assigns.form, params: organization_params) do
      {:ok, organization} ->
        notify_parent({:saved, organization})

        socket =
          socket
          |> put_flash(:info, "Organization #{socket.assigns.form.source.type}d successfully")
          |> push_patch(to: socket.assigns.patch)

        {:noreply, socket}

      {:error, form} ->
        {:noreply, assign(socket, form: form)}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})

  defp assign_form(%{assigns: %{organization: organization}} = socket) do
    form =
      if organization do
        AshPhoenix.Form.for_update(organization, :update,
          as: "organization",
          actor: socket.assigns.current_user
        )
      else
        AshPhoenix.Form.for_create(Kindkaboom.Organizations.Organization, :create,
          as: "organization",
          actor: socket.assigns.current_user
        )
      end

    assign(socket, form: to_form(form))
  end
end
