defmodule Exagg.ItemTest do
  use Exagg.ModelCase

  alias Exagg.Item

  @valid_attrs %{content: "some content", date: "2010-04-17 14:00:00", favorite: true, guid: "some content", last_update: "2010-04-17 14:00:00", medias: "some content", orig_feed_title: "some content", read: true, title: "some content", url: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Item.changeset(%Item{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Item.changeset(%Item{}, @invalid_attrs)
    refute changeset.valid?
  end
end
