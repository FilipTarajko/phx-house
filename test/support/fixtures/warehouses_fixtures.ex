defmodule House.WarehousesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `House.Warehouses` context.
  """

  @doc """
  Generate a warehouse.
  """
  def warehouse_fixture(attrs \\ %{}) do
    {:ok, warehouse} =
      attrs
      |> Enum.into(%{
        name: "some name"
      })
      |> House.Warehouses.create_warehouse()

    warehouse
  end

  @doc """
  Generate a product.
  """
  def product_fixture(attrs \\ %{}) do
    {:ok, product} =
      attrs
      |> Enum.into(%{
        danger_quantity: 42,
        description: "some description",
        name: "some name",
        quantity: 42,
        safe_quantity: 42
      })
      |> House.Warehouses.create_product()

    product
  end

  @doc """
  Generate a member.
  """
  def member_fixture(attrs \\ %{}) do
    {:ok, member} =
      attrs
      |> Enum.into(%{
        is_admin: true
      })
      |> House.Warehouses.create_member()

    member
  end
end
