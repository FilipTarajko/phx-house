defmodule House.Repo.Migrations.CreateWarehouses do
  use Ecto.Migration

  def change do
    create table(:warehouses) do
      add :name, :string

      timestamps(type: :utc_datetime)
    end
  end
end
