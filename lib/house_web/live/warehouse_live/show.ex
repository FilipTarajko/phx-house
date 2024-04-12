defmodule HouseWeb.WarehouseLive.Show do
  use HouseWeb, :live_view

  alias House.Warehouses

  @impl true
  def mount(params, _session, socket) do
    {:ok, stream(socket, :members, Warehouses.list_members(params["id"]))}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:warehouse, Warehouses.get_warehouse!(id))
    }
  end

  @impl true
  def handle_event("invite", params, socket) do
    user = House.Accounts.get_user_by_email(params["email"])
    if !user do
      {:noreply, socket |> put_flash(:error, "User not found")}
    else
      warehouse_id = params["warehouse_id"]
      {:ok, member} = Warehouses.create_member(%{user_id: user.id, warehouse_id: warehouse_id, is_admin: false})
      {:noreply, stream_insert(socket, :members, member |> House.Repo.preload(:user))}
      # {:noreply, socket |> put_flash(:info, "User invited")}
    end
  end

  defp page_title(:show), do: "Show Warehouse"
  defp page_title(:edit), do: "Edit Warehouse"
end
