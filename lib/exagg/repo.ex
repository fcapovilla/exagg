defmodule Exagg.Repo do
  use Ecto.Repo, otp_app: :exagg
  use Scrivener, page_size: 20
end
