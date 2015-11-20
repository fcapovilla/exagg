defmodule Exagg.ItemView do
  use Exagg.Web, :view

  def render("index.json", %{items: items}) do
    %{items: render_many(items, Exagg.ItemView, "item.json")}
  end

  def render("show.json", %{item: item}) do
    %{items: render_one(item, Exagg.ItemView, "item.json")}
  end

  def render("item.json", %{item: item}) do
    %{id: item.id,
      title: item.title,
      url: item.url,
      guid: item.guid,
      content: item.content,
      read: item.read,
      favorite: item.favorite,
      date: item.date,
      orig_feed_title: item.orig_feed_title,
      user_id: item.user_id,
      feed_id: item.feed_id}
  end
end
