defmodule Apollo.Repo do
  use Ecto.Repo,
    otp_app: :apollo,
    adapter: Ecto.Adapters.Postgres
end
