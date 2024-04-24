defmodule HouseWeb.WarehouseLive.Index do
  use HouseWeb, :live_view

  alias House.Warehouses
  alias House.Warehouses.Warehouse

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Phoenix.PubSub.subscribe(House.PubSub, "warehouses")
    end

    {:ok, stream(socket, :warehouses, Warehouses.list_warehouses(socket.assigns.current_user.id))}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
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
  def handle_info(%{inserted_warehouse: warehouse, users_to_be_shown_update: users_to_be_shown_update}, socket) do
    if Enum.any?(users_to_be_shown_update, fn user_id -> user_id == socket.assigns.current_user.id end) do
      {:noreply, stream_insert(socket, :warehouses, warehouse)}
    else
      {:noreply, socket}
    end
  end
  def handle_info(%{deleted_warehouse: warehouse, users_to_be_shown_update: users_to_be_shown_update}, socket) do
    if Enum.any?(users_to_be_shown_update, fn user_id -> user_id == socket.assigns.current_user.id end) do
      {:noreply, stream_delete(socket, :warehouses, warehouse)}
    else
      {:noreply, socket}
    end
  end
end
