defmodule HouseWeb.ProductLive.Show do
  use HouseWeb, :live_view

  @impl true
  def mount(params, _session, socket) do
    if !House.Warehouses.is_member?(params["warehouse_id"], socket.assigns.current_user.id) do
      {:ok, socket |> put_flash(:error, gettext "You are not a member of this warehouse") |> redirect(to: "/warehouses")}
    else
      {:ok, socket}
    end
  end

  @impl true
  def handle_params(%{"product_id" => _product_id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
    }
  end

  defp page_title(:show), do: "Show Product"
  defp page_title(:edit), do: "Edit Product"
end
