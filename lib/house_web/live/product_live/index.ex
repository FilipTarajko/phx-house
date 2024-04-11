defmodule HouseWeb.ProductLive.Index do
  use HouseWeb, :live_view

  alias House.Warehouses
  alias House.Warehouses.Product

  @impl true
  def mount(params, _session, socket) do
    socket = socket
    |> assign(:warehouseId, params["warehouseId"])
    |> assign(:warehouseName, Warehouses.get_warehouse!(params["warehouseId"]).name)

    if connected?(socket) do
      Phoenix.PubSub.subscribe(House.PubSub, "warehouse_#{params["warehouseId"]}_products")
    end

    {:ok, stream(socket, :products, Warehouses.list_products(params["warehouseId"]))}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Product")
    |> assign(:product, Warehouses.get_product!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Product")
    |> assign(:product, %Product{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Products")
    |> assign(:product, nil)
  end

  @impl true
  def handle_info({HouseWeb.ProductLive.FormComponent, {:saved, product}}, socket) do
    {:noreply, stream_insert(socket, :products, product)}
  end

  def handle_info(%{inserted_product: product}, socket) do
    {:noreply, stream_insert(socket, :products, product)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    product = Warehouses.get_product!(id)
    {:ok, _} = Warehouses.delete_product(product)

    {:noreply, stream_delete(socket, :products, product)}
  end

  def handle_event("inc", %{"product_id" => product_id}, socket) do
    product = Warehouses.get_product!(product_id)
    {:ok, product} = Warehouses.update_product(product, %{quantity: product.quantity + 1})

    # update the product in the live view
    {:noreply, stream_insert(socket, :products, product)}
  end

  def handle_event("dec", %{"product_id" => product_id}, socket) do
    product = Warehouses.get_product!(product_id)
    {:ok, product} = Warehouses.update_product(product, %{quantity: product.quantity - 1})

    # update the product in the live view
    {:noreply, stream_insert(socket, :products, product)}
  end
end
