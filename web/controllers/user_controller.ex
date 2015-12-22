defmodule Exagg.UserController do
  use Exagg.Web, :controller

  import Comeonin.Bcrypt, only: [hashpwsalt: 1, checkpw: 2]

  alias Exagg.User

  plug :scrub_params, "data" when action in [:create, :update]
  plug Exagg.Plugs.TokenAuth when not action in [:login]
  plug Exagg.Plugs.JsonApiToEcto, "data" when action in [:create, :update]

  def index(conn, _params) do
    users = Repo.all(User)
    render(conn, "index.json", users: users)
  end

  def create(conn, %{"data" => user_params}) do
    changeset = User.changeset(%User{}, user_params)
    |> hash_password

    case Repo.insert(changeset) do
      {:ok, user} ->
        conn
        |> put_status(:created)
        |> put_resp_header("location", user_path(conn, :show, user))
        |> render("show.json", user: user)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(Exagg.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    user = Repo.get!(User, id)
    render(conn, "show.json", user: user)
  end

  def update(conn, %{"id" => id, "data" => user_params}) do
    user = Repo.get!(User, id)
    changeset = User.changeset(user, user_params)
    |> hash_password

    case Repo.update(changeset) do
      {:ok, user} ->
        render(conn, "show.json", user: user)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(Exagg.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    user = Repo.get!(User, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(user)

    send_resp(conn, :no_content, "")
  end

  def login(conn, %{"username" => username, "password" => password}) do
    user = Repo.get_by(User, username: username)
    if user && checkpw(password, user.hashed_password) do
      render(conn, "user.json", %{token: Phoenix.Token.sign(conn, "user", user.id), user: user})
    else
      send_resp(conn, 403, "Access denied")
    end
  end
  def login(conn, _params) do
    send_resp(conn, 403, "Access denied")
  end

  defp hash_password(changeset) do
    case changeset.params["password"] do
      nil -> changeset
      "********" -> changeset
      password -> Ecto.Changeset.put_change(changeset, :hashed_password, hashpwsalt(password))
    end
  end
end
