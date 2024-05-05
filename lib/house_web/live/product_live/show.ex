defmodule HouseWeb.ProductLive.Show do
  use HouseWeb, :live_view

  alias House.Warehouses

  @impl true
  def mount(params, _session, socket) do
    if !House.Warehouses.is_member?(params["warehouse_id"], socket.assigns.current_user.id) do
      {:ok, socket |> put_flash(:error, "You are not a member of this warehouse") |> redirect(to: "/warehouses")}
    else
      socket = socket
      |> assign(:warehouse_id, params["warehouse_id"])
      |> assign(:warehouseName, Warehouses.get_warehouse!(params["warehouse_id"]).name)
      {:ok, socket}
    end
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:product, Warehouses.get_product!(id))}
  end

  defp page_title(:show), do: "Show Product"
  defp page_title(:edit), do: "Edit Product"
end
