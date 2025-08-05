defmodule Acrogoop.Repo do
  use Ecto.Repo,
    otp_app: :acrogoop,
    adapter: Ecto.Adapters.SQLite3
end
