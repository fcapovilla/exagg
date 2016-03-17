defmodule Exagg.SettingsController do
  use Exagg.Web, :controller

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
    require Poison
    require Timex
    alias Exagg.Item
    alias Exagg.Feed

    json = File.read!(file.path) |> Poison.decode!
    user_id = conn.assigns[:user]["id"]

    Enum.each(json["items"], fn(data) ->
      item = %Item{
        user_id: user_id,
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
        url: cond do
          data["canonical"] -> data["canonical"] |> List.first |> Map.get("href")
          data["alternate"] -> data["alternate"] |> List.first |> Map.get("href")
        end,
      }

      item = %{item | guid: item.url}

      if data["categories"] do
        item = Enum.find_value(data["categories"], fn(cat) ->
          if cat =~ ~r/\/state\/com\.google\/read$/ do
            %{item | read: true}
          end
        end)
      end

      # TODO: Add medias import
      #if data["enclosure"] do
      #  item.medias = Enum.map(data["enclosure"], fn(enclosure) ->
      #    medias[enclosure["type"]] = enclosure["href"]
      #  end)
      #end

      Repo.transaction fn ->
        feed_url = data["origin"]["streamId"] |> String.slice(5..-1)
        feed = Feed |> Repo.filter(conn) |> Ecto.Query.where([f], f.url == ^feed_url) |> Repo.one
        if feed != nil do
          item = %{item | feed_id: feed.id}
          existing = Repo.one(from i in Item, where: i.url == ^item.url and i.title == ^item.title and i.feed_id == ^item.feed_id)

          if existing != nil do
            Repo.update!(Item.changeset(existing, %{favorite: true}))
          else
            item = %{item | feed_id: feed.id}
            Repo.insert!(item)
          end
        else
          item = %{item | orig_feed_title: data["origin"]["title"]}
          Repo.insert!(item)
        end
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
    require Poison
    require Timex
    alias Exagg.Item
    alias Exagg.Feed
    import Paratize.Pool

    json = File.read!(file.path) |> Poison.decode!
    user_id = conn.assigns[:user]["id"]

    parallel_each(json["feeds"], fn(data) ->
      feed_url = data["url"]
      feed = Feed |> Repo.filter(conn) |> Ecto.Query.where([f], f.url == ^feed_url) |> Repo.one
      if feed != nil do
        Enum.each(data["items"], fn(entry) ->
          # TODO: Add medias.
          item = %Item{
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

          Repo.transaction fn ->
            existing = Repo.one(from i in Item, where: i.guid == ^item.guid and i.user_id == ^item.user_id and i.feed_id == ^item.feed_id)

            if existing != nil do
              Repo.update!(Item.changeset(existing, Map.from_struct item))
            else
              Repo.insert!(item)
            end
          end

          Repo.update_unread_count(feed)
        end)
      end
    end, timeout: 60000)
  end

  def sync(conn, _params) do
    Exagg.Syncer.sync_all
    redirect conn, to: folder_path(conn, :index)
  end
end
