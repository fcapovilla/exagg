defmodule Exagg.FeedController do
  use Exagg.Web, :controller

  alias Exagg.Feed

  plug :scrub_params, "data" when action in [:create, :update]
  plug Exagg.Plugs.JWTAuth
  plug Exagg.Plugs.JsonApiToEcto, "data" when action in [:create, :update]

  def index(conn, %{"folder_id" => folder_id}) do
    feeds =
      (from f in Feed,
      where: f.folder_id == ^folder_id)
      |> Repo.filter(conn)
      |> Repo.sort(conn)
      |> Repo.all

    render(conn, "index.json", feeds: feeds)
  end

  def index(conn, _params) do
    feeds = Feed |> Repo.filter(conn) |> Repo.all

    render(conn, "index.json", feeds: feeds)
  end

  def create(conn, %{"data" => feed_params}) do
    changeset =
      Feed.changeset(%Feed{user_id: conn.assigns[:user]["id"], position: 1}, feed_params)
      |> fetch_favicon

    case Repo.insert(changeset) do
      {:ok, feed} ->
        {:ok, feeds} = Repo.update_ordering(Feed, feed, :folder_id)
        {:ok, feed} = Exagg.Syncer.sync_feed(feed)

        conn
        |> put_status(:created)
        |> put_resp_header("location", feed_path(conn, :show, feed))
        |> render("show.json", %{
             feed: feed,
             sideload: [{feeds, Exagg.FeedView, "feed.json"}],
             broadcast: {"jsonapi:stream:" <> to_string(feed.user_id), "new"}
           })
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(Exagg.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    feed = Feed |> Repo.filter(conn) |> Repo.get!(id)

    render(conn, "show.json", feed: feed)
  end

  def update(conn, %{"id" => id, "data" => feed_params}) do
    feed = Feed |> Repo.filter(conn) |> Repo.get!(id)

    changeset =
      Feed.changeset(feed, feed_params)
      |> fetch_favicon

    case Repo.update(changeset) do
      {:ok, feed} ->
        {:ok, feeds} = Repo.update_ordering(Feed, feed, :folder_id)
        feed = Enum.find(feeds, fn(x) -> x.id == feed.id end) || feed

        render(conn, "show.json", %{
          feed: feed,
          sideload: [{feeds, Exagg.FeedView, "feed.json"}],
          broadcast: {"jsonapi:stream:" <> to_string(feed.user_id), "new"}
        })
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(Exagg.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    feed = Feed |> Repo.filter(conn) |> Repo.get!(id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(feed)

    Exagg.Endpoint.broadcast("jsonapi:stream:" <> to_string(feed.user_id), "delete", %{type: "feed", id: id})

    send_resp(conn, :no_content, "")
  end

  defp fetch_favicon(changeset) do
    case Exagg.FaviconFetcher.fetch(Ecto.Changeset.get_field(changeset, :url)) do
      {:ok, favicon} -> Ecto.Changeset.put_change(changeset, :favicon_id, favicon.id)
      {:error, _} -> changeset
    end
  end
end
