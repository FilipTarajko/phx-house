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

  describe "products" do
    alias House.Warehouses.Product

    import House.WarehousesFixtures

    @invalid_attrs %{name: nil, description: nil, quantity: nil, danger_quantity: nil, safe_quantity: nil}

    test "list_products/0 returns all products" do
      product = product_fixture()
      assert Warehouses.list_products() == [product]
    end

    test "get_product!/1 returns the product with given id" do
      product = product_fixture()
      assert Warehouses.get_product!(product.id) == product
    end

    test "create_product/1 with valid data creates a product" do
      valid_attrs = %{name: "some name", description: "some description", quantity: 42, danger_quantity: 42, safe_quantity: 42}

      assert {:ok, %Product{} = product} = Warehouses.create_product(valid_attrs)
      assert product.name == "some name"
      assert product.description == "some description"
      assert product.quantity == 42
      assert product.danger_quantity == 42
      assert product.safe_quantity == 42
    end

    test "create_product/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Warehouses.create_product(@invalid_attrs)
    end

    test "update_product/2 with valid data updates the product" do
      product = product_fixture()
      update_attrs = %{name: "some updated name", description: "some updated description", quantity: 43, danger_quantity: 43, safe_quantity: 43}

      assert {:ok, %Product{} = product} = Warehouses.update_product(product, update_attrs)
      assert product.name == "some updated name"
      assert product.description == "some updated description"
      assert product.quantity == 43
      assert product.danger_quantity == 43
      assert product.safe_quantity == 43
    end

    test "update_product/2 with invalid data returns error changeset" do
      product = product_fixture()
      assert {:error, %Ecto.Changeset{}} = Warehouses.update_product(product, @invalid_attrs)
      assert product == Warehouses.get_product!(product.id)
    end

    test "delete_product/1 deletes the product" do
      product = product_fixture()
      assert {:ok, %Product{}} = Warehouses.delete_product(product)
      assert_raise Ecto.NoResultsError, fn -> Warehouses.get_product!(product.id) end
    end

    test "change_product/1 returns a product changeset" do
      product = product_fixture()
      assert %Ecto.Changeset{} = Warehouses.change_product(product)
    end
  end
end
