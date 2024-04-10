defmodule House.Repo do
  use Ecto.Repo,
    otp_app: :house,
    adapter: Ecto.Adapters.Postgres
end
