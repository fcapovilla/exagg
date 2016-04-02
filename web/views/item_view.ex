defmodule Exagg.ItemView do
  use Exagg.Web, :view

  # Add total_pages metadata to data
  def render("index.json", params = %{total_pages: total_pages}) do
    %{meta: %{total_pages: total_pages}}
    |> Map.merge(render("index.json", Map.delete(params, :total_pages)))
  end

  def render("index.json", %{items: items, sideload: sideloads}) do
    %{data: render_many(items, Exagg.ItemView, "item.json", %{sideload: sideloads}),
      included: sideload_relations([], items, sideloads)
    }
  end

  def render("index.json", %{items: items}) do
    %{data: render_many(items, Exagg.ItemView, "item.json")}
  end

  def render("show.json", %{item: item, sideload: sideloads}) do
    %{data: render_one(item, Exagg.ItemView, "item.json", %{sideload: sideloads}),
      included: sideload_relations([], [item], sideloads)
    }
  end

  def render("show.json", %{item: item}) do
    %{data: render_one(item, Exagg.ItemView, "item.json")}
  end

  def render("item.json", %{item: item, sideload: sideloads}) do
    render("item.json", %{item: item})
    |> insert_relationships(item, sideloads)
  end
  def render("item.json", %{item: item}) do
    %{type: "items",
      id: item.id,
      attributes: %{
        title: item.title,
        url: item.url,
        guid: item.guid,
        content: item.content,
        read: item.read,
        favorite: item.favorite,
        date: item.date,
        "orig-feed-title": item.orig_feed_title,
      },
      relationships: %{
        feed: %{
          data: if item.feed_id do %{type: "feeds", id: item.feed_id} end
        },
        medias: %{
          links: %{
            related: "./medias"
          }
        },
      }
    }
  end
end
