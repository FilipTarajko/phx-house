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
end
