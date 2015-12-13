defmodule Exagg.FaviconFetcher do
  require Logger

  alias Exagg.Favicon
  alias Exagg.Repo

  def fetch(url) do
    uri = URI.parse(url)
    host = uri.scheme <> "://" <> uri.authority

    # Check for existing favicon
    case Repo.get_by(Favicon, host: host) do
      nil ->
        case download_favicon(host) do
          {:ok, favicon} -> {:ok, Repo.insert!(favicon)}
          {:error, e} -> {:error, e}
        end
      favicon -> {:ok, favicon}
    end
  end

  def download_favicon(host) do
    favicon = %Favicon{host: host}
    url = host <> "/favicon.ico"

    # Try to download a favicon
    data = try do
      case HTTPotion.get(url) do
        %HTTPotion.Response{body: body, headers: headers} ->
          if headers[:"Content-Type"] =~ ~r/^image\/.*icon$/ do
            Base.encode64(body)
          end
        _ -> nil
      end
    rescue
      _ -> nil
    end

    if data == nil and not(url =~ ~r/www/) do
      data = try do
        # Try the url with a "www"
        url = Regex.replace(~r/^(https?:\/\/)[^.\/]+(\.[^.\/]+(\.[^.\/]+)+\/.*)$/, url, "\\1www\\2")
        case HTTPotion.get(url) do
          %HTTPotion.Response{body: body, headers: headers} ->
            if headers[:"Content-Type"] =~ ~r/^image\/.*icon$/ do
              Base.encode64(body)
            end
          _ -> nil
        end
      rescue
        _ -> nil
      end
    end

    case data do
      nil -> {:error, "Error fetching " <> url}
      data -> {:ok, %{favicon | data: data}}
    end
  end
end
