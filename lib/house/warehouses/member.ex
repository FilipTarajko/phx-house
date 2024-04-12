defmodule House.Warehouses.Member do
  use Ecto.Schema
  import Ecto.Changeset

  schema "members" do
    field :is_admin, :boolean, default: false
    belongs_to :user, House.Accounts.User
    belongs_to :warehouse, House.Warehouses.Warehouse

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(member, attrs) do
    member
    |> cast(attrs, [:is_admin, :user_id, :warehouse_id])
    |> validate_required([:is_admin, :user_id, :warehouse_id])
  end
end
