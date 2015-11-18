defmodule Exagg.FeedView do
  use Exagg.Web, :view

  def render("index.json", %{feeds: feeds}) do
    %{feeds: render_many(feeds, Exagg.FeedView, "feed.json")}
  end

  def render("show.json", %{feed: feed}) do
    %{feeds: render_one(feed, Exagg.FeedView, "feed.json")}
  end

  def render("feed.json", %{feed: feed}) do
    %{id: feed.id,
      title: feed.title,
      url: feed.url,
      last_sync: feed.last_sync,
      unread_count: feed.unread_count,
      sync_status: feed.sync_status,
      favicon: feed.favicon,
      user_id: feed.user_id,
      folder_id: feed.folder_id,
      position: feed.position,
      links: %{
        items: "./items"
      }
    }
  end
end
