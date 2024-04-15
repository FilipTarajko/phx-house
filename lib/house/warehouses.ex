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

      iex> list_warehouses()
      [%Warehouse{}, ...]

  """
  def list_warehouses do
    Repo.all(Warehouse)
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
    %Warehouse{}
    |> Warehouse.changeset(attrs)
    |> Repo.insert()
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
    warehouse
    |> Warehouse.changeset(attrs)
    |> Repo.update()
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
      {:ok, member} -> Phoenix.PubSub.broadcast(House.PubSub, "warehouse_#{member.warehouse_id}_members", %{inserted_member: member |> Repo.preload(:user)})
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
    result = Repo.delete(member)

    Phoenix.PubSub.broadcast(House.PubSub, "warehouse_#{member.warehouse_id}_members", %{deleted_member: member})

    result
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
end
