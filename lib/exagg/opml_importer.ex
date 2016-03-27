defmodule Exagg.OPMLImporter do
  alias Exagg.Folder
  alias Exagg.Repo
  alias Exagg.Feed

  def import(file, conn) do
    alias XmlNode, as: Xml

    user_id = conn.assigns[:user]["id"]
    doc = Xml.from_file file.path
    Enum.each(Xml.all(doc, "body/outline"), fn(node) ->
      case Xml.attr(node, "type") do
        "rss" ->
          folder = Folder |> Repo.filter(conn) |> Repo.get_by(title: "Feeds") || Repo.insert!(%Folder{title: "Feeds", user_id: user_id})
          favicon_id = case Exagg.FaviconFetcher.fetch(Xml.attr(node, "xmlUrl")) do
            {:ok, favicon} -> favicon.id
            {:error, _} -> nil
          end
          Repo.insert(%Feed{
            folder_id: folder.id,
            title: Xml.attr(node, "title"),
            url: Xml.attr(node, "xmlUrl"),
            user_id: user_id,
            favicon_id: favicon_id
          })
        _ ->
          title = Xml.attr(node, "title") || Xml.attr(node, "text")
          folder = Folder |> Repo.filter(conn) |> Repo.get_by(title: title) || Repo.insert!(%Folder{title: title, user_id: user_id})
          Enum.each(Xml.all(node, "outline"), fn(node) ->
            favicon_id = case Exagg.FaviconFetcher.fetch(Xml.attr(node, "xmlUrl")) do
              {:ok, favicon} -> favicon.id
              {:error, _} -> nil
            end
            Repo.insert(%Feed{
              folder_id: folder.id,
              title: Xml.attr(node, "title"),
              url: Xml.attr(node, "xmlUrl"),
              user_id: user_id,
              favicon_id: favicon_id
            })
          end)
      end
    end)
  end
end
