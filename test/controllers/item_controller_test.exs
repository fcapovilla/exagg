defmodule Exagg.ItemControllerTest do
  use Exagg.ConnCase

  alias Exagg.Item
  @valid_attrs %{content: "some content", date: "2010-04-17 14:00:00", favorite: true, guid: "some content", last_update: "2010-04-17 14:00:00", medias: "some content", orig_feed_title: "some content", read: true, title: "some content", url: "some content"}
  @invalid_attrs %{}

  setup do
    conn = conn() |> put_req_header("accept", "application/json")
    {:ok, conn: conn}
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, item_path(conn, :index)
    assert json_response(conn, 200)["data"] == []
  end

  test "shows chosen resource", %{conn: conn} do
    item = Repo.insert! %Item{}
    conn = get conn, item_path(conn, :show, item)
    assert json_response(conn, 200)["data"] == %{"id" => item.id,
      "title" => item.title,
      "url" => item.url,
      "guid" => item.guid,
      "content" => item.content,
      "medias" => item.medias,
      "read" => item.read,
      "favorite" => item.favorite,
      "date" => item.date,
      "last_update" => item.last_update,
      "orig_feed_title" => item.orig_feed_title,
      "user_id" => item.user_id,
      "feed_id" => item.feed_id}
  end

  test "does not show resource and instead throw error when id is nonexistent", %{conn: conn} do
    assert_raise Ecto.NoResultsError, fn ->
      get conn, item_path(conn, :show, -1)
    end
  end

  test "creates and renders resource when data is valid", %{conn: conn} do
    conn = post conn, item_path(conn, :create), item: @valid_attrs
    assert json_response(conn, 201)["data"]["id"]
    assert Repo.get_by(Item, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, item_path(conn, :create), item: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "updates and renders chosen resource when data is valid", %{conn: conn} do
    item = Repo.insert! %Item{}
    conn = put conn, item_path(conn, :update, item), item: @valid_attrs
    assert json_response(conn, 200)["data"]["id"]
    assert Repo.get_by(Item, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    item = Repo.insert! %Item{}
    conn = put conn, item_path(conn, :update, item), item: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "deletes chosen resource", %{conn: conn} do
    item = Repo.insert! %Item{}
    conn = delete conn, item_path(conn, :delete, item)
    assert response(conn, 204)
    refute Repo.get(Item, item.id)
  end
end
