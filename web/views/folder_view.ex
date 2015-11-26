defmodule Exagg.FolderView do
  use Exagg.Web, :view

  alias Exagg.Repo

  def render("index.json", params = %{folders: folders}) do
    sideload = Map.get(params, :sideload, false)
    data = render_many(folders, Exagg.FolderView, "folder.json", %{sideload: sideload})

    if sideload do
      data = data ++ Enum.map(folders, fn folder ->
        render_many(folder.feeds, Exagg.FeedView, "feed.json")
      end)
    end

    %{data: List.flatten(data)}
  end

  def render("show.json", %{folder: folder}) do
    %{data: render_one(folder, Exagg.FolderView, "folder.json")}
  end

  def render("folder.json", params = %{folder: folder}) do
    data = %{type: "folders",
      id: folder.id,
      attributes: %{
        title: folder.title,
        open: folder.open,
        position: folder.position,
      },
      relationships: %{
        feeds: %{
          links: %{
            related: "./feeds"
          }
        },
        items: %{
          links: %{
            related: "./items"
          }
        }
      }
    }

    sideload = Map.get(params, :sideload, false)
    if sideload do
      relation_data = %{data: Enum.map(folder.feeds, fn feed -> %{type: "feeds", id: feed.id} end)}
      data.relationships.feeds
      |> update_in(&Map.merge(&1, relation_data))
    else
      data
    end
  end
end
