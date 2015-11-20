defmodule Exagg.MediaTest do
  use Exagg.ModelCase

  alias Exagg.Media

  @valid_attrs %{type: "some content", url: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Media.changeset(%Media{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Media.changeset(%Media{}, @invalid_attrs)
    refute changeset.valid?
  end
end
