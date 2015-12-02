defmodule Exagg.ItemController do
  use Exagg.Web, :controller

  alias Exagg.Item
  alias Exagg.Feed

  plug :scrub_params, "data" when action in [:create, :update]
  plug Exagg.Plugs.JsonApiToEcto, "data" when action in [:create, :update]

  def index(conn, params = %{"folder_id" => folder_id}) do
    query =
      from i in Item,
      join: f in Feed, on: i.feed_id == f.id,
      where: f.folder_id == ^folder_id
    page = query |> filter(params) |> Repo.paginate(params)
    render(conn, "index.json", items: page.entries, total_pages: page.total_pages)
  end

  def index(conn, params = %{"feed_id" => feed_id}) do
    query =
      from i in Item,
      where: i.feed_id == ^feed_id
    page = query |> filter(params) |> Repo.paginate(params)
    render(conn, "index.json", items: page.entries, total_pages: page.total_pages)
  end

  def index(conn, params) do
    query = from i in Item
    page = query |> filter(params) |> Repo.paginate(params)
    render(conn, "index.json", items: page.entries, total_pages: page.total_pages)
  end

  def create(conn, %{"data" => item_params}) do
    changeset = Item.changeset(%Item{}, item_params)

    case Repo.insert(changeset) do
      {:ok, item} ->
        conn
        |> put_status(:created)
        |> put_resp_header("location", item_path(conn, :show, item))
        |> render("show.json", item: item)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(Exagg.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    item = Repo.get!(Item, id)
    render(conn, "show.json", item: item)
  end

  def update(conn, %{"id" => id, "data" => item_params}) do
    item = Repo.get!((from i in Item, join: f in assoc(i, :feed), preload: [feed: f]), id)
    changeset = Item.changeset(item, item_params)

    case Repo.update(changeset) do
      {:ok, item} ->
        # Update feed unread count
        {:ok, feed} = Repo.transaction fn ->
          feed = item.feed
          count = Repo.one(from i in Item, where: i.feed_id == ^feed.id and i.read == false, select: count(i.id))
          Repo.update!(Feed.changeset(feed, %{unread_count: count}))
        end
        item = %{item | feed: feed}

        render(conn, "show.json", item: item, sideload: [:feed])
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(Exagg.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    item = Repo.get!(Item, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(item)

    send_resp(conn, :no_content, "")
  end

  defp filter(query, params) do
    case params["filter"] do
      nil -> query
      filters ->
        Enum.reduce(filters, query, fn {col, val}, query ->
          from i in query, where: field(i, ^String.to_atom(col)) == ^val
        end)
    end
  end

  defp count(query) do
    from i in query, select: count(i.id)
  end
end
