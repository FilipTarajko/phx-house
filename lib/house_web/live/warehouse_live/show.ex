defmodule HouseWeb.WarehouseLive.Show do
  use HouseWeb, :live_view

  alias House.Warehouses

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:warehouse, Warehouses.get_warehouse!(id))}
  end

  defp page_title(:show), do: "Show Warehouse"
  defp page_title(:edit), do: "Edit Warehouse"
end
