defmodule Exagg.Media do
  use Exagg.Web, :model

  embedded_schema do
    field :type, :string
    field :url, :string

    timestamps
  end
end
