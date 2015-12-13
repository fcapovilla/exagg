defmodule Exagg.FaviconControllerTest do
  use Exagg.ConnCase

  alias Exagg.Favicon
  @valid_attrs %{data: "some content", url: "some content"}
  @invalid_attrs %{}

  setup do
    conn = conn() |> put_req_header("accept", "application/json")
    {:ok, conn: conn}
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, favicon_path(conn, :index)
    assert json_response(conn, 200)["data"] == []
  end

  test "shows chosen resource", %{conn: conn} do
    favicon = Repo.insert! %Favicon{}
    conn = get conn, favicon_path(conn, :show, favicon)
    assert json_response(conn, 200)["data"] == %{"id" => favicon.id,
      "url" => favicon.url,
      "data" => favicon.data}
  end

  test "does not show resource and instead throw error when id is nonexistent", %{conn: conn} do
    assert_raise Ecto.NoResultsError, fn ->
      get conn, favicon_path(conn, :show, -1)
    end
  end

  test "creates and renders resource when data is valid", %{conn: conn} do
    conn = post conn, favicon_path(conn, :create), favicon: @valid_attrs
    assert json_response(conn, 201)["data"]["id"]
    assert Repo.get_by(Favicon, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, favicon_path(conn, :create), favicon: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "updates and renders chosen resource when data is valid", %{conn: conn} do
    favicon = Repo.insert! %Favicon{}
    conn = put conn, favicon_path(conn, :update, favicon), favicon: @valid_attrs
    assert json_response(conn, 200)["data"]["id"]
    assert Repo.get_by(Favicon, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    favicon = Repo.insert! %Favicon{}
    conn = put conn, favicon_path(conn, :update, favicon), favicon: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "deletes chosen resource", %{conn: conn} do
    favicon = Repo.insert! %Favicon{}
    conn = delete conn, favicon_path(conn, :delete, favicon)
    assert response(conn, 204)
    refute Repo.get(Favicon, favicon.id)
  end
end
