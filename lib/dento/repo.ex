defmodule Dento.Repo do
  use Ecto.Repo,
    otp_app: :dento,
    adapter: Ecto.Adapters.SQLite3
end
