defmodule HouseWeb.WarehouseLive.Index do
  use HouseWeb, :live_view

  alias House.Warehouses
  alias House.Warehouses.Warehouse

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :warehouses, Warehouses.list_warehouses())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Warehouse")
    |> assign(:warehouse, Warehouses.get_warehouse!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Warehouse")
    |> assign(:warehouse, %Warehouse{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Warehouses")
    |> assign(:warehouse, nil)
  end

  @impl true
  def handle_info({HouseWeb.WarehouseLive.FormComponent, {:saved, warehouse}}, socket) do
    {:noreply, stream_insert(socket, :warehouses, warehouse)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    warehouse = Warehouses.get_warehouse!(id)
    {:ok, _} = Warehouses.delete_warehouse(warehouse)

    {:noreply, stream_delete(socket, :warehouses, warehouse)}
  end
end
