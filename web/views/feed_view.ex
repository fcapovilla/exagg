defmodule Exagg.FeedView do
  use Exagg.Web, :view
  use JaSerializer.PhoenixView

  location "/feeds/:id"
  attributes [:title, :url, :last_sync, :unread_count, :sync_status, :favicon_id, :position]

  has_one :folder,
    serializer: Exagg.FolderView,
    field: :folder_id

  has_many :items,
    #serializer: Exagg.ItemView,
    links: [
      related: "./items"
    ]
end
