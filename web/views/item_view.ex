defmodule Exagg.ItemView do
  use Exagg.Web, :view

  def render("index.json", %{items: items}) do
    %{data: render_many(items, Exagg.ItemView, "item.json")}
  end

  def render("show.json", %{item: item}) do
    %{data: render_one(item, Exagg.ItemView, "item.json")}
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
          data: %{
            type: "feeds",
            id: item.feed_id
          }
        }
      }
    }
  end
end
