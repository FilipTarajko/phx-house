defmodule HouseWeb.WarehouseLive.Show do
  use HouseWeb, :live_view

  alias House.Warehouses

  @impl true
  def mount(params, _session, socket) do
    {:ok,
      socket
      |> stream(:members, Warehouses.list_members(params["id"]))
      |> assign(invitation_form: to_form(%{"email" => ""}))
    }
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
  def handle_event("validate_invitation", %{"email" => email}, socket) do
    {:noreply, assign(socket, invitation_form: to_form(%{"email" => email}))}
  end

  def handle_event("save_invitation", %{"email" => email}, socket) do
    user = House.Accounts.get_user_by_email(email)
    if !user do
      {:noreply, socket |> put_flash(:error, "User not found")}
    else
      warehouse_id = socket.assigns.warehouse.id
      is_user_already_a_member = Warehouses.list_members(warehouse_id) |> Enum.any?(fn member -> member.user_id == user.id end)
      if is_user_already_a_member do
        {:noreply, socket |> put_flash(:error, "User is already a member")}
      else
        {:ok, member} = Warehouses.create_member(%{user_id: user.id, warehouse_id: warehouse_id, is_admin: false})
        {:noreply, stream_insert(socket, :members, member |> House.Repo.preload(:user))}
      end
    end
  end

  defp page_title(:show), do: "Show Warehouse"
  defp page_title(:edit), do: "Edit Warehouse"

end
