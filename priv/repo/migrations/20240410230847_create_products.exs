defmodule House.Repo.Migrations.CreateProducts do
  use Ecto.Migration

  def change do
    create table(:products) do
      add :name, :string
      add :quantity, :integer, default: 0
      add :danger_quantity, :integer, null: true
      add :safe_quantity, :integer, null: true
      add :description, :string, default: ""

      timestamps(type: :utc_datetime)
    end
  end
end
