defmodule Exagg.ItemController do
  use Exagg.Web, :controller

  alias Exagg.Item

  plug :scrub_params, "data" when action in [:create, :update]
  plug Exagg.Plugs.JWTAuth
  plug Exagg.Plugs.JsonApiToEcto, "data" when action in [:create, :update]

  def index(conn, %{"folder_id" => folder_id}) do
    items =
      (from i in Item,
      join: f in assoc(i, :feed),
      where: f.folder_id == ^folder_id,
      preload: [:medias])
      |> Repo.filter(conn)
      |> Repo.sort(conn)
      |> Repo.paginate(conn)
      |> Repo.all

    render(conn, "index.json", items: items, sideload: [:medias])
  end

  def index(conn, %{"feed_id" => feed_id}) do
    items =
      (from i in Item,
      where: i.feed_id == ^feed_id,
      preload: [:medias])
      |> Repo.filter(conn)
      |> Repo.sort(conn)
      |> Repo.paginate(conn)
      |> Repo.all

    render(conn, "index.json", items: items, sideload: [:medias])
  end

  def index(conn, _params) do
    items =
      Item
      |> Ecto.Query.preload(:medias)
      |> Repo.filter(conn)
      |> Repo.sort(conn)
      |> Repo.paginate(conn)
      |> Repo.all

    render(conn, "index.json", items: items, sideload: [:medias])
  end

  def create(conn, %{"data" => item_params}) do
    changeset = Item.changeset(%Item{user_id: conn.assigns[:user]["id"]}, item_params)

    case Repo.insert(changeset) do
      {:ok, item} ->
        conn
        |> put_status(:created)
        |> put_resp_header("location", item_path(conn, :show, item))
        |> render("show.json", item: item, broadcast: {"jsonapi:stream", "new:items"})
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(Exagg.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    item = Item |> Repo.filter(conn) |> Repo.get!(id)

    render(conn, "show.json", item: item)
  end

  def update(conn, %{"id" => id, "data" => item_params}) do
    item =
      (from i in Item, left_join: f in assoc(i, :feed), preload: [feed: f])
      |> Repo.filter(conn)
      |> Repo.get!(id)

    changeset = Item.changeset(item, item_params)

    case Repo.update(changeset) do
      {:ok, item} ->
        {:ok, feed} = Repo.update_unread_count(item.feed)
        item = %{item | feed: feed}

        render(conn, "show.json", item: item, sideload: [:feed], broadcast: {"jsonapi:stream", "new:items"})
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(Exagg.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    item = Item |> Repo.filter(conn) |> Repo.get!(id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(item)

    send_resp(conn, :no_content, "")
  end
end
