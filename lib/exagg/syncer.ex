defmodule Exagg.Syncer do
  require Logger

  alias Exagg.Feed
  alias Exagg.Item
  alias Exagg.Repo

  import Ecto.Query

  use Timex
  import Pipe
  import Paratize.Pool

  def sync_all do
    Feed
    |> where([f], datetime_add(f.last_sync, f.update_frequency, "minute") < ^Ecto.DateTime.utc)
    |> Repo.all
    |> parallel_each(&sync_feed(&1), timeout: 20000)

    %{sync: "ok"}
  end

  # Update items for the feed in parameter.
  def sync_feed(feed) do
    with {:ok, data} <- fetch_data(feed.url),
         {:ok, parsed_feed} <- parse_feed(data)
    do
      update_feed(feed, parsed_feed)
    else
      {:error, code} ->
        # Try to get a string representation of the error
        code = case code do
          str when is_bitstring(str) -> str
          %{message: message} -> message
          %{__struct__: code} -> to_string(code)
          _ -> "Unknown error"
        end

        Logger.error "Error syncing " <> feed.url <> " : " <> code
        feed |> Feed.changeset(%{sync_status: code}) |> Repo.update!
    end
  end

  # Recalculate the sync frequency of all feeds using automatic frequency calculation
  # The frequency goes from one every 30 minutes (30) to once every week (10080)
  def recalculate_sync_frequencies do
    Feed
    |> where(auto_frequency: true)
    |> Repo.all
    |> Enum.each(fn(feed) ->
      Repo.transaction fn ->
        month_count =
          Item
          |> select([i], count(i.id))
          |> where(feed_id: ^feed.id)
          |> where([i], i.date > ago(30, "day"))
          |> Repo.one

        frequency = if month_count < 360 do
          round(30/(month_count+1)*6*60)
        else
          30
        end

        feed |> Feed.changeset(%{update_frequency: frequency}) |> Repo.update!
      end
    end)
  end

  # Update items for the feed in parameter using the parsed_feed.
  defp update_feed(feed, parsed_feed) do
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
          [%{url: entry.enclosure.url, type: entry.enclosure.type}]
        else
          []
        end
      }
    end)

    # Update feed items
    Repo.transaction fn ->
      existings = Repo.all(from i in Item, where: i.guid in ^Enum.map(items, &(&1.guid)) and i.user_id == ^feed.user_id and i.feed_id == ^feed.id, preload: [:medias])

      updated_items = Enum.map(items, fn(item) ->
        existing = Enum.find(existings, &(&1.guid == item.guid))
        if existing do
          changeset = existing |> Item.changeset(item)
          if changeset.changes != %{} do
            Repo.update!(changeset)
          else
            false
          end
        else
          %Item{} |> Item.changeset(item) |> Repo.insert!
        end
      end)
      |> Enum.filter(&(&1))

      feed_changes = %{
        title: if parsed_feed.title == "" do feed.title else parsed_feed.title end,
        last_sync: Ecto.DateTime.utc,
        sync_status: ""
      }

      if updated_items != [] do
        # Update feed data
        {:ok, updated_feed} = Repo.update_unread_count(feed, feed_changes)

        # Broadcast changes
        Exagg.FeedView.render("show.json", %{
          feed: updated_feed,
          sideload: [{updated_items, Exagg.ItemView, "item.json"}],
          broadcast: {"jsonapi:stream:" <> to_string(updated_feed.user_id), "new"}
        })

        updated_feed
      else
        feed |> Feed.changeset(feed_changes) |> Repo.update!
      end
    end
  end

  # Fetch data from the URL in parameter.
  defp fetch_data(url) do
    try do
      case HTTPotion.get(url, [follow_redirects: true, headers: ["User-Agent": "Exagg"]]) do
        %HTTPotion.Response{body: body} -> {:ok, body}
        %HTTPotion.ErrorResponse{message: message} -> {:error, message}
      end
    rescue
      ex -> {:error, ex}
    end
  end

  # Parse XML feed data.
  defp parse_feed(xml) do
    try do
       case FeederEx.parse(xml) do
          {:ok, feed, _} -> {:ok, feed}
          {:error, code} -> {:error, code}
       end
    rescue
      ex -> {:error, ex}
    catch
      ex -> {:error, ex}
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
