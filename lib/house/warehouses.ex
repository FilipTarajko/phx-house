defmodule House.Warehouses do
  @moduledoc """
  The Warehouses context.
  """

  import Ecto.Query, warn: false
  alias House.Repo

  alias House.Warehouses.Warehouse

  @doc """
  Returns the list of warehouses.

  ## Examples

      iex> list_warehouses(user_id)
      [%Warehouse{}, ...]

  """
  def list_warehouses(user_id) do
    Repo.all(
      from w in Warehouse,
      join: m in assoc(w, :members),
      where: m.user_id == ^user_id,
      select: w
    )
  end

  @doc """
  Gets a single warehouse.

  Raises `Ecto.NoResultsError` if the Warehouse does not exist.

  ## Examples

      iex> get_warehouse!(123)
      %Warehouse{}

      iex> get_warehouse!(456)
      ** (Ecto.NoResultsError)

  """
  def get_warehouse!(id), do: Repo.get!(Warehouse, id)

  @doc """
  Creates a warehouse.

  ## Examples

      iex> create_warehouse(%{field: value})
      {:ok, %Warehouse{}}

      iex> create_warehouse(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_warehouse(attrs \\ %{}) do
    result = %Warehouse{}
    |> Warehouse.changeset(attrs)
    |> Repo.insert()

    case result do
      {:ok, warehouse} -> Phoenix.PubSub.broadcast(House.PubSub, "warehouses", %{inserted_warehouse: warehouse, users_to_be_shown_update: [attrs["owner_id"]]})
      _ -> nil
    end

    result
  end

  @doc """
  Updates a warehouse.

  ## Examples

      iex> update_warehouse(warehouse, %{field: new_value})
      {:ok, %Warehouse{}}

      iex> update_warehouse(warehouse, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_warehouse(%Warehouse{} = warehouse, attrs) do
    warehouse_changeset = warehouse
    |> Warehouse.changeset(attrs)

    result = Repo.update(warehouse_changeset)

    users_to_be_shown_update = Enum.map(list_members(warehouse.id), fn member ->
      member.user_id
    end)

    case result do
      {:ok, warehouse} ->
        Phoenix.PubSub.broadcast(House.PubSub, "warehouses", %{inserted_warehouse: warehouse, users_to_be_shown_update: users_to_be_shown_update})
        Phoenix.PubSub.broadcast(House.PubSub, "warehouse_#{warehouse.id}", %{updated_warehouse: warehouse |> Repo.preload(:owner)})
      _ -> nil
    end

    result
  end

  @doc """
  Deletes a warehouse.

  ## Examples

      iex> delete_warehouse(warehouse)
      {:ok, %Warehouse{}}

      iex> delete_warehouse(warehouse)
      {:error, %Ecto.Changeset{}}

  """
  def delete_warehouse(%Warehouse{} = warehouse) do
    users_to_be_shown_update = Enum.map(list_members(warehouse.id), fn member ->
      member.user_id
    end)

    Phoenix.PubSub.broadcast(House.PubSub, "warehouse_#{warehouse.id}", :deleted_warehouse)
    Phoenix.PubSub.broadcast(House.PubSub, "warehouses", %{deleted_warehouse: warehouse, users_to_be_shown_update: users_to_be_shown_update})
    Repo.delete(warehouse)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking warehouse changes.

  ## Examples

      iex> change_warehouse(warehouse)
      %Ecto.Changeset{data: %Warehouse{}}

  """
  def change_warehouse(%Warehouse{} = warehouse, attrs \\ %{}) do
    Warehouse.changeset(warehouse, attrs)
  end

  alias House.Warehouses.Product

  @doc """
  Returns the list of products.

  ## Examples

      iex> list_products()
      [%Product{}, ...]

  """
  def list_products(warehouse_id) do
    Repo.all(
      from p in Product,
      where: p.warehouse_id == ^warehouse_id
    )
  end

  @doc """
  Gets a single product.

  Raises `Ecto.NoResultsError` if the Product does not exist.

  ## Examples

      iex> get_product!(123)
      %Product{}

      iex> get_product!(456)
      ** (Ecto.NoResultsError)

  """
  def get_product!(id), do: Repo.get!(Product, id)

  @doc """
  Creates a product.

  ## Examples

      iex> create_product(%{field: value})
      {:ok, %Product{}}

      iex> create_product(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_product(attrs \\ %{}) do
    product_changeset = %Product{}
    |> Product.changeset(attrs)
    result = Repo.insert(product_changeset)

    case result do
      {:ok, product} -> Phoenix.PubSub.broadcast(House.PubSub, "warehouse_#{product.warehouse_id}_products", %{inserted_product: product})
      _ -> nil
    end

    result
  end

  @doc """
  Updates a product.

  ## Examples

      iex> update_product(product, %{field: new_value})
      {:ok, %Product{}}

      iex> update_product(product, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_product(%Product{} = product, attrs) do
    product_changeset = product
      |> Product.changeset(attrs)
    result = Repo.update(product_changeset)

    case result do
      {:ok, product} -> Phoenix.PubSub.broadcast(House.PubSub, "warehouse_#{product.warehouse_id}_products", %{inserted_product: product})
      _ -> nil
    end

    result
  end

  @doc """
  Deletes a product.

  ## Examples

      iex> delete_product(product)
      {:ok, %Product{}}

      iex> delete_product(product)
      {:error, %Ecto.Changeset{}}

  """
  def delete_product(%Product{} = product) do
    result = Repo.delete(product)

    Phoenix.PubSub.broadcast(House.PubSub, "warehouse_#{product.warehouse_id}_products", %{deleted_product: product})

    result
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking product changes.

  ## Examples

      iex> change_product(product)
      %Ecto.Changeset{data: %Product{}}

  """
  def change_product(%Product{} = product, attrs \\ %{}) do
    Product.changeset(product, attrs)
  end

  alias House.Warehouses.Member

  @doc """
  Returns the list of members.

  ## Examples

      iex> list_members()
      [%Member{}, ...]

  """
  def list_members(warehouse_id) do
    Repo.all(
      from m in Member,
      where: m.warehouse_id == ^warehouse_id
    ) |> Repo.preload(:user)
  end

  @doc """
  Gets a single member.

  Raises `Ecto.NoResultsError` if the Member does not exist.

  ## Examples

      iex> get_member!(123)
      %Member{}

      iex> get_member!(456)
      ** (Ecto.NoResultsError)

  """
  def get_member!(id), do: Repo.get!(Member, id)

  @doc """
  Creates a member.

  ## Examples

      iex> create_member(%{field: value})
      {:ok, %Member{}}

      iex> create_member(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_member(attrs \\ %{}) do
    member_changeset = %Member{}
    |> Member.changeset(attrs)

    result = Repo.insert(member_changeset)

    case result do
      {:ok, member} ->
        member = member |> Repo.preload(:user) |> Repo.preload(:warehouse)
        Phoenix.PubSub.broadcast(House.PubSub, "warehouse_#{member.warehouse_id}_members", %{inserted_member: member})
        if member.user_id != member.warehouse.owner_id do
          Phoenix.PubSub.broadcast(House.PubSub, "warehouses", %{users_to_be_shown_update: [member.user_id], inserted_warehouse: member.warehouse})
        end
      _ -> nil
    end

    result
  end

  @doc """
  Updates a member.

  ## Examples

      iex> update_member(member, %{field: new_value})
      {:ok, %Member{}}

      iex> update_member(member, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_member(%Member{} = member, attrs) do
    member_changeset = member
    |> Member.changeset(attrs)

    result = Repo.update(member_changeset)

    case result do
      {:ok, member} -> Phoenix.PubSub.broadcast(House.PubSub, "warehouse_#{member.warehouse_id}_members", %{inserted_member: member |> Repo.preload(:user)})
      _ -> nil
    end

    result
  end

  @doc """
  Deletes a member.

  ## Examples

      iex> delete_member(member)
      {:ok, %Member{}}

      iex> delete_member(member)
      {:error, %Ecto.Changeset{}}

  """
  def delete_member(%Member{} = member) do
    member = member |> Repo.preload(:warehouse)

    result = Repo.delete(member)

    if member.user_id == member.warehouse.owner_id do
      if Repo.one(from m in Member, where: m.warehouse_id == ^member.warehouse_id, limit: 1) == nil do
        delete_warehouse(member.warehouse)
        Phoenix.PubSub.broadcast(House.PubSub, "warehouses", %{users_to_be_shown_update: [member.user_id], deleted_warehouse: member.warehouse})
        {:ok, :warehouse_deleted}
      else

        new_owner_member = Repo.all(
          from m in Member,
          where: m.warehouse_id == ^member.warehouse_id
        )
        |> Repo.preload(:user)
        |> Enum.sort_by(&(&1.inserted_at))
        |> Enum.sort_by(&{&1.is_admin}, :desc)
        |> List.first()

        transfer_warehouse(member.warehouse, new_owner_member)
        Phoenix.PubSub.broadcast(House.PubSub, "warehouse_#{member.warehouse_id}_members", %{deleted_member: member})
        Phoenix.PubSub.broadcast(House.PubSub, "warehouses", %{users_to_be_shown_update: [member.user_id], deleted_warehouse: member.warehouse})

        result
      end
    else
      Phoenix.PubSub.broadcast(House.PubSub, "warehouse_#{member.warehouse_id}_members", %{deleted_member: member})
      Phoenix.PubSub.broadcast(House.PubSub, "warehouses", %{users_to_be_shown_update: [member.user_id], deleted_warehouse: member.warehouse})
      result
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking member changes.

  ## Examples

      iex> change_member(member)
      %Ecto.Changeset{data: %Member{}}

  """
  def change_member(%Member{} = member, attrs \\ %{}) do
    Member.changeset(member, attrs)
  end


  def is_admin?(warehouse_id, user_id) do
    Repo.one(
      from m in Member,
      where: m.warehouse_id == ^warehouse_id and m.user_id == ^user_id and m.is_admin == true) != nil
  end

  def is_member?(warehouse_id, user_id) do
    Repo.one(
      from m in Member,
      where: m.warehouse_id == ^warehouse_id and m.user_id == ^user_id) != nil
  end

  def transfer_warehouse(warehouse, new_owner_member) do
    old_owner_member = Repo.one(
      from m in Member,
      where:
        m.warehouse_id == ^warehouse.id
        and m.is_admin == true
        and m.user_id == ^warehouse.owner_id
    )

    {:ok, warehouse} = warehouse
    |> update_warehouse(%{owner_id: new_owner_member.user_id})

    if old_owner_member do
      Phoenix.PubSub.broadcast(House.PubSub, "warehouse_#{warehouse.id}_members", %{inserted_member: old_owner_member |> Repo.preload(:user)})
    end

    new_owner_member
    |> update_member(%{is_admin: true})
  end
end
