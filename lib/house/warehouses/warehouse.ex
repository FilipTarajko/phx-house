defmodule House.Warehouses.Warehouse do
  use Ecto.Schema
  import Ecto.Changeset

  schema "warehouses" do
    field :name, :string
    belongs_to :owner, House.Accounts.User
    has_many :products, House.Warehouses.Product, foreign_key: :warehouse_id
    has_many :members, House.Warehouses.Member, foreign_key: :warehouse_id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(warehouse, attrs) do
    warehouse
    |> cast(attrs, [:name, :owner_id])
    |> validate_required([:name, :owner_id])
  end
end
