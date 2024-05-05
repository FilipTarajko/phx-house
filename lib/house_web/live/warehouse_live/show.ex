defmodule HouseWeb.WarehouseLive.Show do
  use HouseWeb, :live_view

  alias House.Warehouses


  @impl true
  def mount(params, _session, socket) do
    if !House.Warehouses.is_member?(params["warehouse_id"], socket.assigns.current_user.id) do
      {:ok, socket |> put_flash(:error, "You are not a member of this warehouse") |> redirect(to: "/warehouses")}
    else
      members = Warehouses.list_members(params["warehouse_id"])
      |> Enum.sort_by(&(&1.user.email))
      |> Enum.sort_by(&{&1.is_admin}, :desc)
      |> Enum.sort_by(&(&1.user_id == Warehouses.get_warehouse!(params["warehouse_id"]).owner_id), :desc)

      socket = socket
        |> stream(:members, members)
        |> assign(invitation_form: to_form(%{"email" => ""}))

      if connected?(socket) do
        Phoenix.PubSub.subscribe(House.PubSub, "warehouse_#{params["warehouse_id"]}_members")
        Phoenix.PubSub.subscribe(House.PubSub, "warehouse_#{params["warehouse_id"]}")
      end
      {:ok, socket}
    end

  end

  @impl true
  def handle_info(%{inserted_member: member}, socket) do
    if member.user_id == socket.assigns.current_user.id do
      socket = socket
        # Force all members rerender to update role-specific buttons
        |> stream(:members, Warehouses.list_members(socket.assigns.warehouse.id))
        |> update_current_members_permission_booleans()
        {:noreply, socket}
    else
      {:noreply, stream_insert(socket, :members, member)}
    end
  end
  def handle_info(%{deleted_member: member}, socket) do
    if member.user_id == socket.assigns.current_user.id do
      socket = socket
        |> put_flash(:error, "You have been removed from the warehouse")
        |> redirect(to: "/warehouses")
        {:noreply, stream_delete(socket, :members, member)}
    else
      {:noreply, stream_delete(socket, :members, member)}
    end
  end
  def handle_info(%{updated_warehouse: warehouse}, socket) do
    {:noreply, assign(socket, :warehouse, warehouse)}
  end
  def handle_info(:deleted_warehouse, socket) do
    {:noreply,
     socket
     |> put_flash(:info, "Warehouse deleted")
     |> redirect(to: "/warehouses")}
  end

  def update_current_members_permission_booleans(socket) do
    socket
    |> assign(:is_owner, socket.assigns.warehouse.owner_id == socket.assigns.current_user.id)
    |> assign(:is_admin, Warehouses.is_admin?(socket.assigns.warehouse.id, socket.assigns.current_user.id))
    |> assign(:is_member, Warehouses.is_member?(socket.assigns.warehouse.id, socket.assigns.current_user.id))
  end

  @impl true
  def handle_params(_params, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> update_current_members_permission_booleans()
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
        {:ok, message} = Warehouses.delete_member(member)
        if message == :warehouse_deleted do
          {:noreply,
           socket
           |> put_flash(:info, "You were the only member - warehouse deleted")
           |> redirect(to: "/warehouses")}
        else
          if member.user_id == socket.assigns.current_user.id do
            warehouse = Warehouses.get_warehouse!(socket.assigns.warehouse.id) |> House.Repo.preload(:owner)
            {:noreply,
              socket
              |> put_flash(:info, "You have left the warehouse, the new owner is #{warehouse.owner.email}")
              |> redirect(to: "/warehouses")
            }
          else
            {:noreply, stream_delete(socket, :members, member)}
          end
        end
      true ->
        {:noreply, socket}
    end
  end

  def handle_event("transfer_warehouse", %{"member_id" => member_id}, socket) do
    requesting_user = House.Accounts.get_user!(socket.assigns.current_user.id)
    new_owner_member = Warehouses.get_member!(member_id) |> House.Repo.preload(:user)
    warehouse = Warehouses.get_warehouse!(socket.assigns.warehouse.id) |> House.Repo.preload(:owner)
    cond do
      warehouse.owner.id != requesting_user.id || warehouse.owner.id == new_owner_member.user_id ->
        {:noreply, socket}
      true ->
        {:ok, _} = Warehouses.transfer_warehouse(warehouse, new_owner_member)
        socket = socket
          |> put_flash(:info, "Warehouse transferred to #{new_owner_member.user.email}")
      {:noreply, socket}
    end
  end

  def handle_event("delete", %{"warehouse_id" => id}, socket) do
    warehouse = Warehouses.get_warehouse!(id)
    if warehouse.owner_id != socket.assigns.current_user.id do
      {:noreply, socket |> put_flash(:error, "Only the owner can delete the warehouse")}
    else
      {:ok, _} = Warehouses.delete_warehouse(warehouse)
      {:noreply,
       socket
       |> put_flash(:info, "Warehouse deleted")
       |> redirect(to: "/warehouses")
      }
    end
  end

  def get_members_role_text(member, warehouse) do
    IO.puts("member: #{inspect(member.user_id)}, warehouse_owner: #{inspect(warehouse.owner_id)}")
    case {warehouse.owner.id, member.user_id, member.is_admin} do
      {x, x, _} -> "owner"
      {_, _, true} -> "admin"
      _ -> "member"
    end
  end

  defp page_title(:show), do: "Show Warehouse"
  defp page_title(:edit), do: "Edit Warehouse"

end
