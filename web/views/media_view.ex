defmodule Exagg.MediaView do
  use Exagg.Web, :view

  def render("index.json", %{medias: medias, sideload: sideload}) do
    %{data: render_many(medias, Exagg.MediaView, "media.json", %{sideload: sideload}),
      included: sideload_relations([], medias, sideload)
    }
  end
  def render("index.json", %{medias: medias}) do
    %{data: render_many(medias, Exagg.MediaView, "media.json")}
  end

  def render("show.json", %{media: media, sideload: sideload}) do
    %{data: render_one(media, Exagg.MediaView, "media.json", %{sideload: sideload}),
      included: sideload_relations([], [media], sideload)
    }
  end
  def render("show.json", %{media: media}) do
    %{data: render_one(media, Exagg.MediaView, "media.json")}
  end

  def render("media.json", %{media: media, sideload: sideload}) do
    render("media.json", %{media: media})
    |> insert_relationships(media, sideload)
  end
  def render("media.json", %{media: media}) do
    %{type: "medias",
      id: media.id,
      attributes: %{
        url: media.url,
        type: media.type
      },
      relationships: %{
        item: %{
          data: %{
            type: "items",
            id: media.item_id
          }
        }
      }
    }
  end
end
