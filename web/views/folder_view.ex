defmodule Exagg.FolderView do
  use Exagg.Web, :view

  def render("index.json", %{folders: folders}) do
    %{folders: render_many(folders, Exagg.FolderView, "folder.json")}
  end

  def render("show.json", %{folder: folder}) do
    %{folders: render_one(folder, Exagg.FolderView, "folder.json")}
  end

  def render("folder.json", %{folder: folder}) do
    %{id: folder.id,
      title: folder.title,
      open: folder.open,
      user: folder.user_id,
      position: folder.position,
      links: %{
        feeds: "./feeds",
        items: "./items"
      }
    }
  end
end
