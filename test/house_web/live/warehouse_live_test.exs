defmodule HouseWeb.WarehouseLiveTest do
  use HouseWeb.ConnCase

  import Phoenix.LiveViewTest
  import House.WarehousesFixtures

  @create_attrs %{name: "some name"}
  @update_attrs %{name: "some updated name"}
  @invalid_attrs %{name: nil}

  defp create_warehouse(_) do
    warehouse = warehouse_fixture()
    %{warehouse: warehouse}
  end

  describe "Index" do
    setup [:create_warehouse]

    test "lists all warehouses", %{conn: conn, warehouse: warehouse} do
      {:ok, _index_live, html} = live(conn, ~p"/warehouses")

      assert html =~ "Listing Warehouses"
      assert html =~ warehouse.name
    end

    test "saves new warehouse", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/warehouses")

      assert index_live |> element("a", "New Warehouse") |> render_click() =~
               "New Warehouse"

      assert_patch(index_live, ~p"/warehouses/new")

      assert index_live
             |> form("#warehouse-form", warehouse: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#warehouse-form", warehouse: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/warehouses")

      html = render(index_live)
      assert html =~ "Warehouse created successfully"
      assert html =~ "some name"
    end

    test "updates warehouse in listing", %{conn: conn, warehouse: warehouse} do
      {:ok, index_live, _html} = live(conn, ~p"/warehouses")

      assert index_live |> element("#warehouses-#{warehouse.id} a", "Edit") |> render_click() =~
               "Edit Warehouse"

      assert_patch(index_live, ~p"/warehouses/#{warehouse}/edit")

      assert index_live
             |> form("#warehouse-form", warehouse: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#warehouse-form", warehouse: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/warehouses")

      html = render(index_live)
      assert html =~ "Warehouse updated successfully"
      assert html =~ "some updated name"
    end

    test "deletes warehouse in listing", %{conn: conn, warehouse: warehouse} do
      {:ok, index_live, _html} = live(conn, ~p"/warehouses")

      assert index_live |> element("#warehouses-#{warehouse.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#warehouses-#{warehouse.id}")
    end
  end

  describe "Show" do
    setup [:create_warehouse]

    test "displays warehouse", %{conn: conn, warehouse: warehouse} do
      {:ok, _show_live, html} = live(conn, ~p"/warehouses/#{warehouse}")

      assert html =~ "Show Warehouse"
      assert html =~ warehouse.name
    end

    test "updates warehouse within modal", %{conn: conn, warehouse: warehouse} do
      {:ok, show_live, _html} = live(conn, ~p"/warehouses/#{warehouse}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Warehouse"

      assert_patch(show_live, ~p"/warehouses/#{warehouse}/show/edit")

      assert show_live
             |> form("#warehouse-form", warehouse: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#warehouse-form", warehouse: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/warehouses/#{warehouse}")

      html = render(show_live)
      assert html =~ "Warehouse updated successfully"
      assert html =~ "some updated name"
    end
  end
end
