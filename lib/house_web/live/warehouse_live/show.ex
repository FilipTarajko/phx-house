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
    warehouse = Warehouses.get_warehouse!(id)
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:warehouse, warehouse)
     |> assign(:is_owner, warehouse.owner_id == socket.assigns.current_user.id)
     |> assign(:is_admin, Warehouses.is_admin?(warehouse.id, socket.assigns.current_user.id))
     |> assign(:is_member, Warehouses.is_member?(warehouse.id, socket.assigns.current_user.id))
    }
  end

  @impl true
  def handle_event("validate_invitation", %{"email" => email}, socket) do
    {:noreply, assign(socket, invitation_form: to_form(%{"email" => email}))}
  end

  def handle_event("save_invitation", %{"email" => email}, socket) do
    user = House.Accounts.get_user_by_email(email)

    cond do
      !socket.assigns.is_admin ->
        {:noreply, socket}

      !user ->
        {:noreply, socket |> put_flash(:error, "User not found")}

      Warehouses.is_member?(socket.assigns.warehouse.id, user.id) ->
        {:noreply, socket |> put_flash(:error, "User is already a member")}

      true ->
        {:ok, member} = Warehouses.create_member(%{user_id: user.id, warehouse_id: socket.assigns.warehouse.id, is_admin: false})
        {:noreply, stream_insert(socket, :members, member |> House.Repo.preload(:user))}
    end
  end

  def handle_event("promote", %{"member_id" => member_id}, socket) do
    cond do
      !socket.assigns.is_owner ->
        {:noreply, socket}
      true ->
        member = Warehouses.get_member!(member_id)
        {:ok, member} = Warehouses.update_member(member, %{is_admin: true})
        {:noreply, stream_insert(socket, :members, member |> House.Repo.preload(:user))}
    end
  end
  def handle_event("demote", %{"member_id" => member_id}, socket) do
    cond do
      !socket.assigns.is_owner ->
        {:noreply, socket}
      true ->
        member = Warehouses.get_member!(member_id)
        {:ok, member} = Warehouses.update_member(member, %{is_admin: false})
        {:noreply, stream_insert(socket, :members, member |> House.Repo.preload(:user))}
    end
  end

  def handle_event("kick", %{"member_id" => member_id}, socket) do
    member = Warehouses.get_member!(member_id)
    cond do
      socket.assigns.is_owner || socket.assigns.is_admin && !member.is_admin || member.user_id == socket.assigns.current_user.id ->
        {:ok, _} = Warehouses.delete_member(member)
        {:noreply, stream_delete(socket, :members, member)}
      true ->
        {:noreply, socket}
    end
  end

  defp page_title(:show), do: "Show Warehouse"
  defp page_title(:edit), do: "Edit Warehouse"

end
