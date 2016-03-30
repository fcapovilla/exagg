defmodule Exagg.JSONItemImporter do
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

    Enum.each(json["feeds"], fn(data) ->
      feed_url = data["url"]
      feed = Feed |> Repo.filter(conn) |> Ecto.Query.where([f], f.url == ^feed_url) |> Ecto.Query.limit(1) |> Repo.one
      if feed != nil do
        items = Enum.map(data["items"], fn(entry) ->
          %{
            title: entry["title"],
            url: entry["url"],
            guid: entry["guid"],
            content: entry["content"],
            read: entry["read"],
            user_id: user_id,
            feed_id: feed.id,
            date: parse_date(entry["date"]),
            medias: find_medias(entry)
          }
        end)

        {:ok, _} = Repo.transaction fn ->
          existings = Repo.all(from i in Item, where: i.guid in ^Enum.map(items, &(&1.guid)) and i.user_id == ^user_id and i.feed_id == ^feed.id)

          changesets = Enum.map(items, fn(item) ->
            existing = Enum.find(existings, &(&1.guid == item.guid))
            if existing do
              existing |> Item.changeset(item)
            else
              %Item{} |> Item.changeset(item)
            end
          end)

          Repo.delete_all(from m in Media, where: m.item_id in ^Enum.map(existings, &(&1.id)))

          Enum.each(changesets, fn(changeset) ->
            item = Repo.insert_or_update!(changeset)

            Enum.map(changeset.params["medias"], fn(media) ->
              media |> Media.changeset(%{item_id: item.id}) |> Repo.insert!
            end)
          end)

          Repo.update_unread_count(feed)
        end
      end
    end)
  end

  defp find_medias(entry) do
    medias = []

    if entry["attachment_url"] do
      medias = [%Media{url: entry["attachment_url"], type: "Download file"}|medias]
    end

    if entry["medias"] do
      medias = medias ++ for {type, url} <- entry["medias"] do
        %Media{url: url, type: type}
      end
    end

    medias
  end

  defp parse_date(date) do
    try do
      date
      |> Timex.parse!("{ISO}")
      |> Timex.format!("{RFC3339z}")
      |> Ecto.DateTime.cast!
    rescue
      _ -> nil
    end
  end
end
