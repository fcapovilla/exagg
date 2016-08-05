defmodule Exagg.FeedView do
  use Exagg.Web, :view

  def render("index.json", %{feeds: feeds, sideload: sideloads}) do
    %{data: render_many(feeds, Exagg.FeedView, "feed.json", %{sideload: sideloads}),
      included: sideload_relations([], feeds, sideloads)
    }
  end
  def render("index.json", %{feeds: feeds}) do
    %{data: render_many(feeds, Exagg.FeedView, "feed.json")}
  end

  def render("show.json", options = %{broadcast: broadcast}) do
    data = render("show.json", Map.delete(options, :broadcast))
    Exagg.Endpoint.broadcast(elem(broadcast, 0), elem(broadcast, 1), data)
    data
  end
  def render("show.json", %{feed: feed, sideload: sideloads}) do
    %{data: render_one(feed, Exagg.FeedView, "feed.json", %{sideload: sideloads}),
      included: sideload_relations([], [feed], sideloads)
    }
  end
  def render("show.json", %{feed: feed}) do
    %{data: render_one(feed, Exagg.FeedView, "feed.json")}
  end

  def render("feed.json", %{feed: feed, sideload: sideloads}) do
    render("feed.json", %{feed: feed})
    |> insert_relationships(feed, sideloads)
  end
  def render("feed.json", %{feed: feed}) do
    %{type: "feeds",
      id: feed.id,
      attributes: %{
        title: feed.title,
        url: feed.url,
        "last-sync": feed.last_sync,
        "update-frequency": feed.update_frequency,
        "auto-frequency": feed.auto_frequency,
        "unread-count": feed.unread_count,
        "sync-status": feed.sync_status,
        "favicon-id": feed.favicon_id,
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
