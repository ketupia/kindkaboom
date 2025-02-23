defmodule KindkaboomWeb.VolunteerLive.FormComponent do
  use KindkaboomWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        {@title}
        <:subtitle>Use this form to manage volunteer records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="volunteer-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:name]} type="text" label="Name" /><.input
          field={@form[:volunteer_interests]}
          type="text"
          label="Volunteer interests"
        />

        <:actions>
          <.button phx-disable-with="Saving...">Save Volunteer</.button>
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
  def handle_event("validate", %{"volunteer" => volunteer_params}, socket) do
    {:noreply,
     assign(socket, form: AshPhoenix.Form.validate(socket.assigns.form, volunteer_params))}
  end

  def handle_event("save", %{"volunteer" => volunteer_params}, socket) do
    case AshPhoenix.Form.submit(socket.assigns.form, params: volunteer_params) do
      {:ok, volunteer} ->
        notify_parent({:saved, volunteer})

        socket =
          socket
          |> put_flash(:info, "Volunteer #{socket.assigns.form.source.type}d successfully")
          |> push_patch(to: socket.assigns.patch)

        {:noreply, socket}

      {:error, form} ->
        {:noreply, assign(socket, form: form)}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})

  defp assign_form(%{assigns: %{volunteer: volunteer}} = socket) do
    form =
      if volunteer do
        AshPhoenix.Form.for_update(volunteer, :update,
          as: "volunteer",
          actor: socket.assigns.current_user
        )
      else
        AshPhoenix.Form.for_create(Kindkaboom.Organizations.Volunteer, :create,
          as: "volunteer",
          actor: socket.assigns.current_user
        )
      end

    assign(socket, form: to_form(form))
  end
end
