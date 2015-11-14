defmodule Exagg.PageController do
  use Exagg.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end

  def opml_upload(conn, %{"opml" => opml}) do
    file = opml["file"]
    case file.content_type do
      "text/x-opml+xml" ->
        import_opml(file)
        conn = put_flash(conn, :info, "OPML file imported")
      _ ->
        conn = put_flash(conn, :error, "Invalid OPML file.")
    end
    render(conn, "index.html")
  end

  defp import_opml(file) do
    alias Exagg.Folder
    alias Exagg.Feed
    alias XmlNode, as: Xml

    doc = Xml.from_file file.path
    Enum.each(Xml.all(doc, "body/outline"), fn(node) ->
      case Xml.attr(node, "type") do
        "rss" ->
          folder = Repo.get_by(Folder, title: "Feeds") || Repo.insert!(%Folder{title: "Feeds"})
          Repo.insert(%Feed{
            folder_id: folder.id,
            title: Xml.attr(node, "title"),
            url: Xml.attr(node, "xmlUrl"),
          })
        _ ->
          title = Xml.attr(node, "title") || Xml.attr(node, "text")
          folder = Repo.get_by(Folder, title: title) || Repo.insert!(%Folder{title: title})
          Enum.each(Xml.all(node, "outline"), fn(node) ->
            Repo.insert(%Feed{
              folder_id: folder.id,
              title: Xml.attr(node, "title"),
              url: Xml.attr(node, "xmlUrl"),
            })
          end)
      end
    end)
  end
end
