defmodule Exagg.SettingsController do
  use Exagg.Web, :controller

  plug Exagg.Plugs.JWTAuth

  def opml_upload(conn, %{"file" => file}) do
    case file.content_type do
      "text/x-opml+xml" ->
        import_opml(conn, file)
        redirect conn, to: folder_path(conn, :index)
      _ ->
        json(conn, %{error: "Invalid OPML file."})
    end
  end

  defp import_opml(conn, file) do
    alias Exagg.Folder
    alias Exagg.Feed
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

  def sync(conn, _params) do
    Exagg.Syncer.sync_all
    redirect conn, to: folder_path(conn, :index)
  end
end
