defmodule Exagg.FaviconController do
  use Exagg.Web, :controller

  alias Exagg.Favicon

  def show(conn, %{"id" => id}) do
    favicon = Repo.get!(Favicon, id)

    conn
    |> put_resp_header("content-type", "image/x-icon")
    |> put_resp_header("cache-control", "public, max-age=604799")
    |> send_resp(200, Base.decode64!(favicon.data))
  end
end
