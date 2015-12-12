defmodule Exagg.FolderController do
  use Exagg.Web, :controller

  alias Exagg.Folder

  plug :scrub_params, "data" when action in [:create, :update]
  plug Exagg.Plugs.TokenAuth
  plug Exagg.Plugs.JsonApiToEcto, "data" when action in [:create, :update]

  def index(conn, _params) do
    folders =
      (from f in Folder,
      left_join: fd in assoc(f, :feeds),
      preload: [feeds: fd])
      |> Repo.filter(conn)
      |> Repo.all

    render(conn, "index.json", folders: folders, sideload: [:feeds])
  end

  def create(conn, %{"data" => folder_params}) do
    changeset = Folder.changeset(%Folder{user_id: conn.assigns[:user_id]}, folder_params)

    case Repo.insert(changeset) do
      {:ok, folder} ->
        conn
        |> put_status(:created)
        |> put_resp_header("location", folder_path(conn, :show, folder))
        |> render("show.json", folder: folder)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(Exagg.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    folder = Folder |> Repo.filter(conn) |> Repo.get!(id)

    render(conn, "show.json", folder: folder)
  end

  def update(conn, %{"id" => id, "data" => folder_params}) do
    folder = Folder |> Repo.filter(conn) |> Repo.get!(id)

    changeset = Folder.changeset(folder, folder_params)

    case Repo.update(changeset) do
      {:ok, folder} ->
        render(conn, "show.json", folder: folder)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(Exagg.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    folder = Folder |> Repo.filter(conn) |> Repo.get!(id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(folder)

    send_resp(conn, :no_content, "")
  end
end
