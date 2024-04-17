defmodule HouseWeb.WarehouseLive.FormComponent do
  use HouseWeb, :live_component

  alias House.Warehouses

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage warehouse records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="warehouse-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:name]} type="text" label="Name" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Warehouse</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{warehouse: warehouse} = assigns, socket) do
    changeset = Warehouses.change_warehouse(warehouse)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"warehouse" => warehouse_params}, socket) do
    changeset =
      socket.assigns.warehouse
      |> Warehouses.change_warehouse(warehouse_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"warehouse" => warehouse_params}, socket) do
    save_warehouse(socket, socket.assigns.action, warehouse_params)
  end

  defp save_warehouse(socket, :edit, warehouse_params) do
    if socket.assigns.warehouse.owner_id != socket.assigns.current_user.id do
      {:noreply, socket}
    else
      case Warehouses.update_warehouse(socket.assigns.warehouse, warehouse_params) do
        {:ok, _warehouse} ->
          # notify_parent({:saved, warehouse})

          {:noreply,
            socket
            |> put_flash(:info, "Warehouse updated successfully")
            |> push_patch(to: socket.assigns.patch)}

        {:error, %Ecto.Changeset{} = changeset} ->
          {:noreply, assign_form(socket, changeset)}
      end
    end
  end

  defp save_warehouse(socket, :new, warehouse_params) do
    params = warehouse_params
    |> Map.put("owner_id", socket.assigns.current_user.id)
    case Warehouses.create_warehouse(params) do
      {:ok, warehouse} ->
        Warehouses.create_member(%{user_id: socket.assigns.current_user.id, warehouse_id: warehouse.id, is_admin: true})
        notify_parent({:saved, warehouse})

        {:noreply,
         socket
         |> put_flash(:info, "Warehouse created successfully")
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
