defmodule Exagg.JSONItemImporter do
  import Ecto.Query, only: [from: 2]

  require Poison
  require Timex

  alias Exagg.Repo
  alias Exagg.Item
  alias Exagg.Feed

  def import(file, conn) do
    json = File.read!(file.path) |> Poison.decode!
    user_id = conn.assigns[:current_user].id

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
          existings = Repo.all(from i in Item, where: i.guid in ^Enum.map(items, &(&1.guid)) and i.user_id == ^user_id and i.feed_id == ^feed.id, preload: [:medias])

          updated_items = Enum.map(items, fn(item) ->
            existing = Enum.find(existings, &(&1.guid == item.guid))
            if existing do
              existing |> Item.changeset(item) |> Repo.update!
            else
              %Item{} |> Item.changeset(item) |> Repo.insert!
            end
          end)

          # Update feed data
          {:ok, updated_feed} = Repo.update_unread_count(feed)

          # Broadcast changes
          Exagg.FeedView.render("show.json", %{
            feed: updated_feed,
            sideload: [{updated_items, Exagg.ItemView, "item.json"}],
            broadcast: {"jsonapi:stream:" <> to_string(updated_feed.user_id), "new"}
          })

          updated_feed
        end
      end
    end)
  end

  defp find_medias(entry) do
    medias =
      if entry["attachment_url"] do
        [%{url: entry["attachment_url"], type: "Download file"}]
      else
        []
      end

    if entry["medias"] do
      medias ++ for {type, url} <- entry["medias"] do
        %{url: url, type: type}
      end
    else
      medias
    end
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
