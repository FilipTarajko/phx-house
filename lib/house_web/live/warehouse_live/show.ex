defmodule HouseWeb.WarehouseLive.Show do
  use HouseWeb, :live_view

  alias House.Warehouses

  @impl true
  def mount(params, _session, socket) do
    members = Warehouses.list_members(params["id"])
    |> Enum.sort_by(&(&1.user.email))
    |> Enum.sort_by(&{&1.is_admin}, :desc)
    |> Enum.sort_by(&(&1.user_id == Warehouses.get_warehouse!(params["id"]).owner_id), :desc)

    socket = socket
      |> stream(:members, members)
      |> assign(invitation_form: to_form(%{"email" => ""}))

    if connected?(socket) do
      Phoenix.PubSub.subscribe(House.PubSub, "warehouse_#{params["id"]}_members")
    end

    {:ok, socket}
  end

  @impl true
  def handle_info(%{inserted_member: member}, socket) do
    if member.user_id == socket.assigns.current_user.id do
      socket = socket
        |> update_current_members_permission_booleans()
        {:noreply, stream_insert(socket, :members, member)}
    else
      {:noreply, stream_insert(socket, :members, member)}
    end
  end
  def handle_info(%{deleted_member: member}, socket) do
    if member.user_id == socket.assigns.current_user.id do
      socket = socket
        |> update_current_members_permission_booleans()
        {:noreply, stream_delete(socket, :members, member)}
    else
      {:noreply, stream_delete(socket, :members, member)}
    end
  end

  def update_current_members_permission_booleans(socket) do
    socket
    |> assign(:is_owner, socket.assigns.warehouse.owner_id == socket.assigns.current_user.id)
    |> assign(:is_admin, Warehouses.is_admin?(socket.assigns.warehouse.id, socket.assigns.current_user.id))
    |> assign(:is_member, Warehouses.is_member?(socket.assigns.warehouse.id, socket.assigns.current_user.id))
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    warehouse = Warehouses.get_warehouse!(id) |> House.Repo.preload(:owner)
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:warehouse, warehouse)
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
        {:ok, _} = Warehouses.delete_member(member)
        {:noreply, stream_delete(socket, :members, member)}
      true ->
        {:noreply, socket}
    end
  end

  def get_members_role_text(member, warehouse) do
    case {warehouse.owner.id, member.user_id, member.is_admin} do
      {x, x, _} -> "owner"
      {_, _, true} -> "admin"
      _ -> "member"
    end
  end

  defp page_title(:show), do: "Show Warehouse"
  defp page_title(:edit), do: "Edit Warehouse"

end
