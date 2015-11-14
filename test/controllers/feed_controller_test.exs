defmodule Exagg.FeedControllerTest do
  use Exagg.ConnCase

  alias Exagg.Feed
  @valid_attrs %{favicon: "some content", last_sync: "2010-04-17 14:00:00", last_update: "2010-04-17 14:00:00", position: 42, sync_status: "some content", title: "some content", unread_count: 42, url: "some content"}
  @invalid_attrs %{}

  setup do
    conn = conn() |> put_req_header("accept", "application/json")
    {:ok, conn: conn}
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, feed_path(conn, :index)
    assert json_response(conn, 200)["data"] == []
  end

  test "shows chosen resource", %{conn: conn} do
    feed = Repo.insert! %Feed{}
    conn = get conn, feed_path(conn, :show, feed)
    assert json_response(conn, 200)["data"] == %{"id" => feed.id,
      "title" => feed.title,
      "url" => feed.url,
      "last_update" => feed.last_update,
      "last_sync" => feed.last_sync,
      "unread_count" => feed.unread_count,
      "sync_status" => feed.sync_status,
      "favicon" => feed.favicon,
      "user_id" => feed.user_id,
      "folder_id" => feed.folder_id,
      "position" => feed.position}
  end

  test "does not show resource and instead throw error when id is nonexistent", %{conn: conn} do
    assert_raise Ecto.NoResultsError, fn ->
      get conn, feed_path(conn, :show, -1)
    end
  end

  test "creates and renders resource when data is valid", %{conn: conn} do
    conn = post conn, feed_path(conn, :create), feed: @valid_attrs
    assert json_response(conn, 201)["data"]["id"]
    assert Repo.get_by(Feed, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, feed_path(conn, :create), feed: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "updates and renders chosen resource when data is valid", %{conn: conn} do
    feed = Repo.insert! %Feed{}
    conn = put conn, feed_path(conn, :update, feed), feed: @valid_attrs
    assert json_response(conn, 200)["data"]["id"]
    assert Repo.get_by(Feed, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    feed = Repo.insert! %Feed{}
    conn = put conn, feed_path(conn, :update, feed), feed: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "deletes chosen resource", %{conn: conn} do
    feed = Repo.insert! %Feed{}
    conn = delete conn, feed_path(conn, :delete, feed)
    assert response(conn, 204)
    refute Repo.get(Feed, feed.id)
  end
end
