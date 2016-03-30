defmodule Exagg.JSONFavoriteImporter do
  import Ecto.Query, only: [from: 1, from: 2]

  require Poison
  require Timex

  alias Exagg.Repo
  alias Exagg.Item
  alias Exagg.Media
  alias Exagg.Feed

  def import(file, conn) do
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
          _ -> nil
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
        feed = Feed |> Repo.filter(conn) |> Ecto.Query.where([f], f.url == ^feed_url) |> Ecto.Query.limit(1) |> Repo.one
        if feed != nil do
          item = %{item | feed_id: feed.id}
          existing = Repo.one(from i in Item, where: i.url == ^item.url and i.title == ^item.title and i.feed_id == ^item.feed_id, limit: 1)

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
end
