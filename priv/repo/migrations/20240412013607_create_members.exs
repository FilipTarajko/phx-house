defmodule House.Repo.Migrations.CreateMembers do
  use Ecto.Migration

  def change do
    create table(:members) do
      add :is_admin, :boolean, default: false, null: false
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :warehouse_id, references(:warehouses, on_delete: :delete_all), null: false

      timestamps(type: :utc_datetime)
    end
  end
end
