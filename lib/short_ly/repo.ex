defmodule ShortLy.Repo do
  use Ecto.Repo,
    otp_app: :short_ly,
    adapter: Ecto.Adapters.Postgres
end
