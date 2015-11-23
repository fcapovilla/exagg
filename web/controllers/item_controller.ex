defmodule Exagg.ItemController do
  use Exagg.Web, :controller

  alias Exagg.Item
  alias Exagg.Feed

  plug :scrub_params, "data" when action in [:create, :update]

  def index(conn, %{"folder_id" => folder_id}) do
    items = Repo.all(
      from i in Item,
      join: f in Feed, on: i.feed_id == f.id,
      where: f.folder_id == ^folder_id,
      select: i
    )
    render(conn, "index.json", items: items)
  end

  def index(conn, %{"feed_id" => feed_id}) do
    items = Repo.all(
      from i in Item,
      where: i.feed_id == ^feed_id
    )
    render(conn, "index.json", items: items)
  end

  def index(conn, _params) do
    items = Repo.all(Item)
    render(conn, "index.json", items: items)
  end

  def create(conn, %{"data" => %{"type" => "items", "attributes" => item_params}}) do
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

  def update(conn, %{"id" => id, "data" => %{"type" => "items", "attributes" => item_params}}) do
    item = Repo.get!(Item, id)
    changeset = Item.changeset(item, item_params)

    case Repo.update(changeset) do
      {:ok, item} ->
        render(conn, "show.json", item: item)
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
end
