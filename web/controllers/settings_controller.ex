defmodule Exagg.SettingsController do
  use Exagg.Web, :controller

  require Poison
  require Timex

  alias Exagg.Folder
  alias Exagg.Item
  alias Exagg.Feed
  alias Exagg.Media

  plug Exagg.Plugs.JWTAuth

  def favorites_upload(conn, %{"file" => file}) do
    case file.content_type do
      "application/json" ->
        import_favorites(conn, file)
        redirect conn, to: folder_path(conn, :index)
      _ ->
        json(conn, %{error: "Invalid JSON file."})
    end
  end

  def import_favorites(conn, file) do
    json = File.read!(file.path) |> Poison.decode!
    user_id = conn.assigns[:user]["id"]

    Enum.each(json["items"], fn(data) ->
      url = cond do
        data["canonical"] -> data["canonical"] |> List.first |> Map.get("href")
        data["alternate"] -> data["alternate"] |> List.first |> Map.get("href")
      end

      read = false
      if data["categories"] do
        read = Enum.any?(data["categories"], fn(cat) ->
          cat =~ ~r/\/state\/com\.google\/read$/
        end)
      end

      item = %{
        user_id: user_id,
        feed_id: nil,
        title: data["title"] || '...',
        date: try do
          data["published"]
          |> Integer.to_string
          |> Timex.parse!("{s-epoch}")
          |> Timex.format!("{RFC3339z}")
          |> Ecto.DateTime.cast!
        rescue
          _ -> Ecto.DateTime.utc
        end,
        favorite: true,
        content: cond do
          data["content"] -> data["content"]["content"]
          data["summary"] -> data["summary"]["content"]
        end,
        url: url,
        guid: url,
        read: read,
        orig_feed_title: nil,
      }

      {:ok, saved_item} = Repo.transaction fn ->
        feed_url = data["origin"]["streamId"] |> String.slice(5..-1)
        feed = Feed |> Repo.filter(conn) |> Ecto.Query.where([f], f.url == ^feed_url) |> Repo.one
        if feed != nil do
          item = %{item | feed_id: feed.id}
          existing = Repo.one(from i in Item, where: i.url == ^item.url and i.title == ^item.title and i.feed_id == ^item.feed_id)

          if existing != nil do
            existing |> Item.changeset(%{favorite: true}) |> Repo.update!
          else
            item = %{item | feed_id: feed.id}
            %Item{} |> Item.changeset(item) |> Repo.insert!
          end
        else
          item = %{item | orig_feed_title: data["origin"]["title"]}
          %Item{} |> Item.changeset(item) |> Repo.insert!
        end
      end

      Repo.delete_all(from m in Media, where: m.item_id == ^saved_item.id)

      if data["enclosure"] do
        Enum.each(data["enclosure"], fn(enclosure) ->
          %Media{}
          |> Media.changeset(%{item_id: saved_item.id, url: enclosure["href"], type: enclosure["type"]})
          |> Repo.insert!
        end)
      end
    end)
  end

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

  def items_upload(conn, %{"file" => file}) do
    case file.content_type do
      "application/json" ->
        import_items(conn, file)
        redirect conn, to: folder_path(conn, :index)
      _ ->
        json(conn, %{error: "Invalid JSON file."})
    end
  end

  defp import_items(conn, file) do
    json = File.read!(file.path) |> Poison.decode!
    user_id = conn.assigns[:user]["id"]

    Enum.each(json["feeds"], fn(data) ->
      feed_url = data["url"]
      feed = Feed |> Repo.filter(conn) |> Ecto.Query.where([f], f.url == ^feed_url) |> Ecto.Query.limit(1) |> Repo.one
      if feed != nil do
        Enum.each(data["items"], fn(entry) ->
          item = %{
            title: entry["title"],
            url: entry["url"],
            guid: entry["guid"],
            content: entry["content"],
            read: entry["read"],
            date: try do
              entry["date"]
              |> Timex.parse!("{ISO}")
              |> Timex.format!("{RFC3339z}")
              |> Ecto.DateTime.cast!
            rescue
              _ -> Ecto.DateTime.utc
            end,
            user_id: user_id,
            feed_id: feed.id,
          }

          {:ok, saved_item} = Repo.transaction fn ->
            existing = Repo.one(from i in Item, where: i.guid == ^item.guid and i.user_id == ^item.user_id and i.feed_id == ^item.feed_id)

            if existing != nil do
              existing |> Item.changeset(item) |> Repo.update!
            else
              %Item{} |> Item.changeset(item) |> Repo.insert!
            end
          end

          Repo.delete_all(from m in Media, where: m.item_id == ^saved_item.id)

          if entry["attachment_url"] do
            %Media{}
            |> Media.changeset(%{item_id: saved_item.id, url: entry["attachment_url"], type: "Download file"})
            |> Repo.insert!
          end

          if entry["medias"] do
            for {type, url} <- entry["medias"] do
              %Media{}
              |> Media.changeset(%{item_id: saved_item.id, url: url, type: type})
              |> Repo.insert!
            end
          end

          Repo.update_unread_count(feed)
        end)
      end
    end)
  end

  def sync(conn, _params) do
    Exagg.Syncer.sync_all
    redirect conn, to: folder_path(conn, :index)
  end
end
