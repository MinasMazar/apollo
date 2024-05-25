defmodule ApolloWeb.VisitLive.FormComponent do
  use ApolloWeb, :live_component

  alias Apollo.Gemini

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage visit records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="visit-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:url]} type="text" label="Url" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Visit</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{visit: visit} = assigns, socket) do
    changeset = Gemini.change_visit(visit)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"visit" => visit_params}, socket) do
    changeset =
      socket.assigns.visit
      |> Gemini.change_visit(visit_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"visit" => visit_params}, socket) do
    save_visit(socket, socket.assigns.action, visit_params)
  end

  defp save_visit(socket, :edit, visit_params) do
    case Gemini.update_visit(socket.assigns.visit, visit_params) do
      {:ok, visit} ->
        notify_parent({:saved, visit})

        {:noreply,
         socket
         |> put_flash(:info, "Visit updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_visit(socket, :new, visit_params) do
    case Gemini.create_visit(visit_params) do
      {:ok, visit} ->
        notify_parent({:saved, visit})

        {:noreply,
         socket
         |> put_flash(:info, "Visit created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
