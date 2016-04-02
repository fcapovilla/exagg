defmodule Exagg.ItemView do
  use Exagg.Web, :view
  use JaSerializer.PhoenixView

  alias Exagg.Repo

  location "/items/:id"
  attributes [:title, :url, :guid, :content, :read, :favorite, :date, :orig_feed_title]

  has_one :feed,
    serializer: Exagg.FeedView,
    field: :feed_id

  has_many :medias,
    serializer: Exagg.MediaView,
    include: true

  def medias(struct, conn) do
    case struct.medias do
      %Ecto.Association.NotLoaded{} ->
        struct
        |> Ecto.assoc(:medias)
        |> Repo.all
      other -> other
    end
  end
end
