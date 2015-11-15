defmodule Exagg.Syncer do
  alias Exagg.Feed
  alias Exagg.Item
  alias Exagg.Repo

  import Ecto.Model
  import Ecto.Query, only: [from: 1, from: 2]
  import Pipe

  def sync do
    Enum.each(Repo.all(Feed), fn feed ->
      # Fetch data
      HTTPoison.start
      {:ok, %HTTPoison.Response{body: body}} = HTTPoison.get(feed.url)

      # Parse it
      {:ok, parsed_feed, _} = FeederEx.parse(body)

      # Update feed items
      Enum.each(parsed_feed.entries, fn entry ->
        item = %{
          feed_id: feed.id,
          title: entry.title || entry.link || entry.id,
          url: entry.link || entry.id,
          content: entry.summary,
          date: elem(parse_date(entry.updated), 1),
          guid: entry.id
        }

        case Repo.get_by(Item, guid: item.guid) do
          nil -> Repo.insert!(Item.changeset(%Item{}, item))
          existing -> Repo.update!(Item.changeset(existing, item))
        end
      end)
    end)
    %{sync: "ok"}
  end

  defp parse_date(date) do
    use Timex

    format = find_dateformat(date)
    IO.inspect format

    pipe_matching(x, {:ok, x},
      case format do
        :unknown ->
          {:ok, Timex.Date.local}
        _ ->
          {:ok, timex} = Timex.DateFormat.parse(date, format)
          {:ok, case timex.timezone do
            {:error, _} -> Timex.Date.set(timex, timezone: Timex.Timezone.get("UTC"))
            _ -> timex
          end}
      end
      |> Timex.DateFormat.format("{RFC3339z}")
      |> Ecto.DateTime.cast
    )
  end

  defp find_dateformat(date) do
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
      true -> :unknown
    end
  end
end
