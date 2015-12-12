defmodule Exagg.Syncer do
  require Logger

  alias Exagg.Feed
  alias Exagg.Item
  alias Exagg.Repo

  import Ecto.Query, only: [from: 2]

  use Timex
  import Pipe
  import Paratize.Pool

  def sync_all do
    Repo.all(Feed) |> parallel_each(&sync_feed(&1), timeout: 10000)
    %{sync: "ok"}
  end

  # Update items for the feed in parameter.
  def sync_feed(feed) do
    parsed_feed = fetch_data(feed.url) |> parse_feed

    # Update feed items
    Enum.each(parsed_feed.entries, fn entry ->
      item = %Item{
        feed_id: feed.id,
        user_id: feed.user_id,
        title: entry.title || entry.link || entry.id,
        url: entry.link || entry.id,
        content: entry.summary,
        date: parse_date(entry.updated),
        guid: entry.id || entry.link
      }

      Repo.transaction fn ->
        existing = Repo.one(from i in Item, where: i.guid == ^item.guid and i.user_id == ^item.user_id)

        if existing != nil do
          Repo.update!(Item.changeset(existing, Map.from_struct item))
        else
          Repo.insert!(item)
        end
      end
    end)

    # Update feed data
    Repo.update_unread_count(feed, %{title: parsed_feed.title})
  end

  # Fetch data from the URL in parameter.
  # Return an empty string on error.
  defp fetch_data(url) do
    try do
      case HTTPotion.get(url) do
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
  # If the date cannot be parsed, return the current date.
  defp parse_date(nil) do Ecto.DateTime.local end
  defp parse_date(date) do
    ecto_date = pipe_matching x, {:ok, x},
      Timex.DateFormat.parse(date, guess_dateformat(date))
      |> fix_timezone
      |> Timex.DateFormat.format("{RFC3339z}")
      |> Ecto.DateTime.cast

    case ecto_date do
      {:ok, x} -> x
      {:error, _} -> Ecto.DateTime.local
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
      date =~ ~r/^\w{3},\s\d{1,2}\s\w{3}\s\d{1,2}\s\d{1,2}:\d{2}:\d{2}\sZ$/i -> "{RFC822z}"
      date =~ ~r/^\w{3},\s\d{1,2}\s\w{3}\s\d{1,2}\s\d{1,2}:\d{2}:\d{2}\s\w{1,2}$/i -> "{RFC822}"
      date =~ ~r/^\w{3},\s\d{1,2}\s\w{3}\s\d{4}\s\d{1,2}:\d{2}:\d{2}\sZ$/i -> "{RFC1123z}"
      date =~ ~r/^\w{3},\s\d{1,2}\s\w{3}\s\d{4}\s\d{1,2}:\d{2}:\d{2}\s\w{3}$/i -> "{WDshort}, {0D} {Mshort} {YYYY} {h24}:{m}:{s} {Zname}"
      date =~ ~r/^\w{3},\s\d{1,2}\s\w{3}\s\d{4}\s\d{1,2}:\d{2}:\d{2}\s[+-]\d{4}$/i -> "{RFC1123}"
      date =~ ~r/^\d{4}-\d{1,2}-\d{1,2}T\d{1,2}:\d{2}:\d{2}Z$/i -> "{RFC3339z}"
      date =~ ~r/^\d{4}-\d{1,2}-\d{1,2}T\d{1,2}:\d{2}:\d{2}[+-]\d{2}:\d{2}$/i -> "{RFC3339}"
      date =~ ~r/^\w{3}\s\w{3}\s\d{1,2}\s\d{1,2}:\d{2}:\d{2}\s\d{4}$/i -> "{ANSIC}"
      date =~ ~r/^\w{3}\s\w{3}\s\d{1,2}\s\d{1,2}:\d{2}:\d{2}\s\w{3}\s\d{4}$/i -> "{UNIX}"
      true -> ""
    end
  end
end
