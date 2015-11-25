defmodule Exagg.FeedController do
  use Exagg.Web, :controller

  alias Exagg.Feed

  plug :scrub_params, "data" when action in [:create, :update]
  plug Exagg.Plugs.JsonApiToEcto, "data" when action in [:create, :update]

  def index(conn, %{"folder_id" => folder_id}) do
    feeds = Repo.all(from f in Feed, where: f.folder_id == ^folder_id)
    render(conn, "index.json", feeds: feeds)
  end

  def index(conn, params) do
    query = from f in Feed
    if params["filter"] do
      query = Enum.reduce(params["filter"], query, fn {col, val}, query ->
        from f in query, where: field(f, ^String.to_atom(col)) == ^val
      end)
    end

    feeds = Repo.all(query)
    render(conn, "index.json", feeds: feeds)
  end

  def create(conn, %{"data" => feed_params}) do
    changeset = Feed.changeset(%Feed{}, feed_params)

    case Repo.insert(changeset) do
      {:ok, feed} ->
        conn
        |> put_status(:created)
        |> put_resp_header("location", feed_path(conn, :show, feed))
        |> render("show.json", feed: feed)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(Exagg.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    feed = Repo.get!(Feed, id)
    render(conn, "show.json", feed: feed)
  end

  def update(conn, %{"id" => id, "data" => feed_params}) do
    feed = Repo.get!(Feed, id)
    changeset = Feed.changeset(feed, feed_params)

    case Repo.update(changeset) do
      {:ok, feed} ->
        render(conn, "show.json", feed: feed)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(Exagg.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    feed = Repo.get!(Feed, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(feed)

    send_resp(conn, :no_content, "")
  end
end
