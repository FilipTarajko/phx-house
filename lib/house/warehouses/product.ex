defmodule House.Warehouses.Product do
  use Ecto.Schema
  import Ecto.Changeset

  schema "products" do
    field :name, :string
    field :description, :string
    field :quantity, :integer, default: 0
    field :danger_quantity, :integer
    field :safe_quantity, :integer
    belongs_to :warehouse, House.Warehouses.Warehouse

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(product, attrs) do
    product
    |> cast(attrs, [:name, :quantity, :danger_quantity, :safe_quantity, :description, :warehouse_id])
    |> validate_required([:name, :warehouse_id])
  end
end
