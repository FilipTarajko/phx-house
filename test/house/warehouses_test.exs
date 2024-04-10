defmodule House.WarehousesTest do
  use House.DataCase

  alias House.Warehouses

  describe "warehouses" do
    alias House.Warehouses.Warehouse

    import House.WarehousesFixtures

    @invalid_attrs %{name: nil}

    test "list_warehouses/0 returns all warehouses" do
      warehouse = warehouse_fixture()
      assert Warehouses.list_warehouses() == [warehouse]
    end

    test "get_warehouse!/1 returns the warehouse with given id" do
      warehouse = warehouse_fixture()
      assert Warehouses.get_warehouse!(warehouse.id) == warehouse
    end

    test "create_warehouse/1 with valid data creates a warehouse" do
      valid_attrs = %{name: "some name"}

      assert {:ok, %Warehouse{} = warehouse} = Warehouses.create_warehouse(valid_attrs)
      assert warehouse.name == "some name"
    end

    test "create_warehouse/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Warehouses.create_warehouse(@invalid_attrs)
    end

    test "update_warehouse/2 with valid data updates the warehouse" do
      warehouse = warehouse_fixture()
      update_attrs = %{name: "some updated name"}

      assert {:ok, %Warehouse{} = warehouse} = Warehouses.update_warehouse(warehouse, update_attrs)
      assert warehouse.name == "some updated name"
    end

    test "update_warehouse/2 with invalid data returns error changeset" do
      warehouse = warehouse_fixture()
      assert {:error, %Ecto.Changeset{}} = Warehouses.update_warehouse(warehouse, @invalid_attrs)
      assert warehouse == Warehouses.get_warehouse!(warehouse.id)
    end

    test "delete_warehouse/1 deletes the warehouse" do
      warehouse = warehouse_fixture()
      assert {:ok, %Warehouse{}} = Warehouses.delete_warehouse(warehouse)
      assert_raise Ecto.NoResultsError, fn -> Warehouses.get_warehouse!(warehouse.id) end
    end

    test "change_warehouse/1 returns a warehouse changeset" do
      warehouse = warehouse_fixture()
      assert %Ecto.Changeset{} = Warehouses.change_warehouse(warehouse)
    end
  end
end
