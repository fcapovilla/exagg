defmodule Exagg.FolderView do
  use Exagg.Web, :view

  def render("index.json", %{folders: folders}) do
    %{data: render_many(folders, Exagg.FolderView, "folder.json")}
  end

  def render("show.json", %{folder: folder}) do
    %{data: render_one(folder, Exagg.FolderView, "folder.json")}
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
