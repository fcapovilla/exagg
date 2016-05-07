defmodule Exagg.FolderView do
  use Exagg.Web, :view

  def render("index.json", %{folders: folders, sideload: sideloads}) do
    %{data: render_many(folders, Exagg.FolderView, "folder.json", %{sideload: sideloads}),
      included: sideload_relations([], folders, sideloads)
    }
  end
  def render("index.json", %{folders: folders}) do
    %{data: render_many(folders, Exagg.FolderView, "folder.json")}
  end

  def render("show.json", options = %{broadcast: broadcast}) do
    data = render("show.json", Map.delete(options, :broadcast))
    Exagg.Endpoint.broadcast(elem(broadcast, 0), elem(broadcast, 1), data)
    data
  end
  def render("show.json", %{folder: folder, sideload: sideloads}) do
    %{data: render_one(folder, Exagg.FolderView, "folder.json", %{sideload: sideloads}),
      included: sideload_relations([], [folder], sideloads)
    }
  end
  def render("show.json", %{folder: folder}) do
    %{data: render_one(folder, Exagg.FolderView, "folder.json")}
  end

  def render("folder.json", %{folder: folder, sideload: sideloads}) do
    render("folder.json", %{folder: folder})
    |> insert_relationships(folder, sideloads)
  end
  def render("folder.json", %{folder: folder}) do
    %{type: "folders",
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
  end
end
