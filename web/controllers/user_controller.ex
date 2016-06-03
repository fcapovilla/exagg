defmodule Exagg.UserController do
  use Exagg.Web, :controller

  import Comeonin.Bcrypt, only: [hashpwsalt: 1, checkpw: 2]

  alias Exagg.User

  plug :scrub_params, "data" when action in [:create, :update]
  plug Exagg.Plugs.JWTAuth when not action in [:token_auth, :token_refresh]
  plug Exagg.Plugs.AdminOnly when action in [:create, :update, :delete]
  plug Exagg.Plugs.JsonApiToEcto, "data" when action in [:create, :update]

  def index(conn, _params) do
    users = Repo.all(User)
    render(conn, "index.json", users: users)
  end

  def create(conn, %{"data" => user_params}) do
    changeset =
      User.changeset(%User{}, user_params)
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
    changeset =
      User.changeset(user, user_params)
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

  def token_auth(conn, %{"username" => username, "password" => password}) do
    user = Repo.get_by(User, username: username)
    if user && checkpw(password, user.hashed_password) do
      jwt = generate_jwt(conn, user)
      render(conn, "user.json", %{token: jwt, user: user})
    else
      deny(conn)
    end
  end
  def token_auth(conn, _params), do: deny(conn)

  def token_refresh(conn, %{"token" => token}) do
    import Joken

    result =
      token
      |> token()
      |> with_signer(hs256(conn.secret_key_base))
      |> with_validation("iat", &(&1 <= current_time))
      |> with_validation("nbf", &(&1 < current_time))
      |> with_validation("exp", &(&1 > current_time))
      |> verify!

    case result do
      {:ok, claims} ->
        user = Repo.get(User, claims["user"]["id"])
        if user do
          jwt = generate_jwt(conn, user)
          render(conn, "user.json", %{token: jwt, user: user})
        else
          deny(conn)
        end
      {:error, _} -> deny(conn)
    end
  end
  def token_refresh(conn, _params), do: deny(conn)

  defp generate_jwt(conn, user) do
    import Joken

    %{user: %{id: user.id, username: user.username, admin: user.admin}}
    |> token
    |> with_signer(hs256(conn.secret_key_base))
    |> with_exp
    |> with_iat
    |> with_nbf
    |> sign
    |> get_compact
  end

  defp deny(conn) do
    send_resp(conn, 403, ~s({"error":"Access denied"}))
  end

  defp hash_password(changeset) do
    case changeset.params["password"] do
      nil -> changeset
      "********" -> changeset
      password -> Ecto.Changeset.put_change(changeset, :hashed_password, hashpwsalt(password))
    end
  end
end
