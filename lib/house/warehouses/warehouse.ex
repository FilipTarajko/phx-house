defmodule House.Warehouses.Warehouse do
  use Ecto.Schema
  import Ecto.Changeset

  schema "warehouses" do
    field :name, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(warehouse, attrs) do
    warehouse
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
