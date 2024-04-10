defmodule House.Repo.Migrations.AddOwnerToWarehouse do
  use Ecto.Migration

  def change do
    alter table(:warehouses) do
      add :owner_id, references(:users, on_delete: :nothing, null: false)
    end
  end
end
