defmodule Exagg.FeedTest do
  use Exagg.ModelCase

  alias Exagg.Feed

  @valid_attrs %{favicon: "some content", last_sync: "2010-04-17 14:00:00", last_update: "2010-04-17 14:00:00", position: 42, sync_status: "some content", title: "some content", unread_count: 42, url: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Feed.changeset(%Feed{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Feed.changeset(%Feed{}, @invalid_attrs)
    refute changeset.valid?
  end
end
