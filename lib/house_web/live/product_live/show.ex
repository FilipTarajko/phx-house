defmodule HouseWeb.ProductLive.Show do
  use HouseWeb, :live_view

  alias House.Warehouses

  @impl true
  def mount(params, _session, socket) do
    socket = socket |> assign(:warehouseId, params["warehouseId"])
    {:ok, socket}
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
