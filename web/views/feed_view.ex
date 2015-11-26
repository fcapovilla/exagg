defmodule Exagg.FeedView do
  use Exagg.Web, :view

  def render("index.json", %{feeds: feeds}) do
    %{data: render_many(feeds, Exagg.FeedView, "feed.json")}
  end

  def render("show.json", %{feed: feed}) do
    %{data: render_one(feed, Exagg.FeedView, "feed.json")}
  end

  def render("feed.json", %{feed: feed}) do
    %{type: "feeds",
      id: feed.id,
      attributes: %{
        title: feed.title,
        url: feed.url,
        "last-sync": feed.last_sync,
        "unread-count": feed.unread_count,
        "sync-status": feed.sync_status,
        favicon: feed.favicon,
        position: feed.position,
      },
      relationships: %{
        items: %{
          links: %{
            related: "./items"
          }
        },
        folder: %{
          data: %{
            type: "folders",
            id: feed.folder_id
          }
        }
      }
    }
  end
end
