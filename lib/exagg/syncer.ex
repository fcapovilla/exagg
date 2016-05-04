defmodule Exagg.Syncer do
  require Logger

  alias Exagg.Feed
  alias Exagg.Item
  alias Exagg.Media
  alias Exagg.Repo
  alias Exagg.Endpoint

  import Ecto.Query, only: [from: 2]

  use Timex
  import Pipe
  import Paratize.Pool

  def sync_all do
    Feed |> Repo.all |> parallel_each(&sync_feed(&1), timeout: 20000)

    # TODO: Send new item data to channel for every feed with new items.
    Endpoint.broadcast("items:stream", "new:items", %{})

    %{sync: "ok"}
  end

  # Update items for the feed in parameter.
  def sync_feed(feed) do
    parsed_feed = feed.url |> fetch_data |> parse_feed

    items = Enum.map(parsed_feed.entries, fn(entry) ->
      %{
        feed_id: feed.id,
        user_id: feed.user_id,
        title: entry.title || entry.link || entry.id,
        url: entry.link || entry.id,
        content: entry.summary,
        date: parse_date(entry.updated),
        guid: entry.id || entry.link,
        medias: if entry.enclosure do
          [%Media{url: entry.enclosure.url, type: entry.enclosure.type}]
        else
          []
        end
      }
    end)

    # Update feed items
    {:ok, _} = Repo.transaction fn ->
      existings = Repo.all(from i in Item, where: i.guid in ^Enum.map(items, &(&1.guid)) and i.user_id == ^feed.user_id and i.feed_id == ^feed.id)

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

      # Update feed data
      Repo.update_unread_count(feed, %{title: if parsed_feed.title == "" do feed.title else parsed_feed.title end})
    end
  end

  # Fetch data from the URL in parameter.
  # Return an empty string on error.
  defp fetch_data(url) do
    try do
      case HTTPotion.get(url, [follow_redirects: true, headers: ["User-Agent": "Exagg"]]) do
        %HTTPotion.Response{body: body} -> body
        _ ->
          Logger.error "Error fetching " <> url
          ""
      end
    rescue
      _ ->
        Logger.error "Error fetching " <> url
        ""
    end
  end

  # Parse XML feed data.
  # Returns an empty list of entries on error.
  defp parse_feed(xml) do
    try do
       case FeederEx.parse(xml) do
          {:ok, feed, _} -> feed
          {:error, _} -> %{entries: [], title: ""}
       end
    rescue
      _ -> %{entries: [], title: ""}
    catch
      _ -> %{entries: [], title: ""}
    end
  end

  # Try to parse the date in parameter and return an Ecto.DateTime.
  # If the date cannot be parsed, return nil.
  defp parse_date(nil) do nil end
  defp parse_date(date) do
    ecto_date = pipe_matching x, {:ok, x},
      Timex.parse(date, guess_dateformat(date))
      |> fix_timezone
      |> Timex.format("{RFC3339z}")
      |> Ecto.DateTime.cast

    case ecto_date do
      {:ok, x} -> x
      {:error, _} -> nil
    end
  end

  # Fix broken timezones in Timex.DateTime structs
  defp fix_timezone(date) do
    case date.timezone do
      {:error, _} ->
        {:ok, Timex.Date.set(date, timezone: Timex.Timezone.get("UTC"))}
      _ -> {:ok, date}
    end
  end

  # Guess the Timex date format for the date in parameter.
  defp guess_dateformat(date) do
    cond do
      date =~ ~r/^\w{3},\s\d{1,2}\s\w{3}\s\d{1,2}\s\d{1,2}:\d{2}:\d{2}\sZ$/i -> "{RFC822z}"
      date =~ ~r/^\w{3},\s\d{1,2}\s\w{3}\s\d{1,2}\s\d{1,2}:\d{2}:\d{2}\s\w{1,2}$/i -> "{RFC822}"
      date =~ ~r/^\w{3},\s\d{1,2}\s\w{3}\s\d{4}\s\d{1,2}:\d{2}:\d{2}\sZ$/i -> "{RFC1123z}"
      date =~ ~r/^\w{3},\s\d{1,2}\s\w{3}\s\d{4}\s\d{1,2}:\d{2}:\d{2}\s\w{3}$/i -> "{WDshort}, {0D} {Mshort} {YYYY} {h24}:{m}:{s} {Zname}"
      date =~ ~r/^\w{3},\s\d{1,2}\s\w{3}\s\d{4}\s\d{1,2}:\d{2}:\d{2}\s[+-]\d{4}$/i -> "{RFC1123}"
      date =~ ~r/^\d{4}-\d{1,2}-\d{1,2}T\d{1,2}:\d{2}:\d{2}Z$/i -> "{RFC3339z}"
      date =~ ~r/^\d{4}-\d{1,2}-\d{1,2}T\d{1,2}:\d{2}:\d{2}[+-]\d{2}:\d{2}$/i -> "{RFC3339}"
      date =~ ~r/^\w{3}\s\w{3}\s\d{1,2}\s\d{1,2}:\d{2}:\d{2}\s\d{4}$/i -> "{ANSIC}"
      date =~ ~r/^\w{3}\s\w{3}\s\d{1,2}\s\d{1,2}:\d{2}:\d{2}\s\w{3}\s\d{4}$/i -> "{UNIX}"

      date =~ ~r/^\d{1,2}\s[a-z]{4,}\s\d{4}\s\d{1,2}:\d{2}:\d{2}$/i -> "{0D} {Mfull} {YYYY} {h24}:{m}:{s}"
      date =~ ~r/^\d{1,2}\s[a-z]{3}\s\d{4}\s\d{1,2}:\d{2}:\d{2}$/i -> "{0D} {Mshort} {YYYY} {h24}:{m}:{s}"
      date =~ ~r/^\d{4}\/\d{1,2}\/\d{1,2}\s\d{1,2}:\d{2}:\d{2}$/i -> "{YYYY}/{0M}/{0D} {h24}:{m}:{s}"
      date =~ ~r/^\d{1,2}\/\d{1,2}\/\d{4}\s\d{1,2}:\d{2}:\d{2}$/i -> "{0M}/{0D}/{YYYY} {h24}:{m}:{s}"
      date =~ ~r/^\d{4}-\d{1,2}-\d{1,2}\s\d{1,2}:\d{2}:\d{2}$/i -> "{YYYY}-{0M}-{0D} {h24}:{m}:{s}"
      date =~ ~r/^\d{1,2}-\d{1,2}-\d{4}\s\d{1,2}:\d{2}:\d{2}$/i -> "{0D}-{0M}-{YYYY} {h24}:{m}:{s}"
      date =~ ~r/^\d{8}\s\d{6}$/i -> "{YYYY}{0M}{0D} {h24}{m}{s}"
      date =~ ~r/^\d{14}$/i -> "{YYYY}{0M}{0D}{h24}{m}{s}"

      date =~ ~r/^\d{1,2}\s[a-z]{4,}\s\d{4}\s\d{1,2}:\d{2}$/i -> "{0D} {Mfull} {YYYY} {h24}:{m}"
      date =~ ~r/^\d{1,2}\s[a-z]{3}\s\d{4}\s\d{1,2}:\d{2}$/i -> "{0D} {Mshort} {YYYY} {h24}:{m}"
      date =~ ~r/^\d{4}\/\d{1,2}\/\d{1,2}\s\d{1,2}:\d{2}$/i -> "{YYYY}/{0M}/{0D} {h24}:{m}"
      date =~ ~r/^\d{1,2}\/\d{1,2}\/\d{4}\s\d{1,2}:\d{2}$/i -> "{0M}/{0D}/{YYYY} {h24}:{m}"
      date =~ ~r/^\d{4}-\d{1,2}-\d{1,2}\s\d{1,2}:\d{2}$/i -> "{YYYY}-{0M}-{0D} {h24}:{m}"
      date =~ ~r/^\d{1,2}-\d{1,2}-\d{4}\s\d{1,2}:\d{2}$/i -> "{0D}-{0M}-{YYYY} {h24}:{m}"
      date =~ ~r/^\d{8}\s\d{4}$/i -> "{YYYY}{0M}{0D} {h24}{m}"
      date =~ ~r/^\d{12}$/i -> "{YYYY}{0M}{0D}{h24}{m}"

      date =~ ~r/^\d{1,2}\s[a-z]{4,}\s\d{4}$/i -> "{0D} {Mfull} {YYYY}"
      date =~ ~r/^\d{1,2}\s[a-z]{3}\s\d{4}$/i -> "{0D} {Mshort} {YYYY}"
      date =~ ~r/^\d{4}\/\d{1,2}\/\d{1,2}$/i -> "{YYYY}/{0M}/{0D}"
      date =~ ~r/^\d{1,2}\/\d{1,2}\/\d{4}$/i -> "{0M}/{0D}/{YYYY}"
      date =~ ~r/^\d{4}-\d{1,2}-\d{1,2}$/i -> "{YYYY}-{0M}-{0D}"
      date =~ ~r/^\d{1,2}-\d{1,2}-\d{4}$/i -> "{0D}-{0M}-{YYYY}"
      date =~ ~r/^\d{8}$/i -> "{YYYY}{0M}{0D}"

      true -> ""
    end
  end
end
