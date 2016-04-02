defmodule Exagg.MediaView do
  use Exagg.Web, :view
  use JaSerializer.PhoenixView

  location "/medias/:id"
  attributes [:url, :type]

  has_one :item,
    serializer: Exagg.ItemView,
    field: :item_id
end
