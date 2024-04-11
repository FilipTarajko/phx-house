defmodule House.Repo.Migrations.AddProductToWarehouseRelation do
  use Ecto.Migration

  def change do
    alter table(:products) do
      add :warehouse_id, references(:warehouses, on_delete: :delete_all, null: false)
    end
  end
end
