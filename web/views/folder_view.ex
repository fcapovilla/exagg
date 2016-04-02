defmodule Exagg.FolderView do
  use Exagg.Web, :view
  use JaSerializer.PhoenixView

  location "/folders/:id"
  attributes [:title, :open, :position]

  has_many :items,
    #serializer: Exagg.ItemView,
    links: [
      related: "./items"
    ]

  has_many :feeds,
    serializer: Exagg.FeedView,
    include: true

  def feeds(struct, conn) do
    case struct.feeds do
      %Ecto.Association.NotLoaded{} ->
        struct
        |> Ecto.assoc(:feeds)
        |> Repo.all
      other -> other
    end
  end
end
