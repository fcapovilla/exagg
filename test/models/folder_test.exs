defmodule Exagg.FolderTest do
  use Exagg.ModelCase

  alias Exagg.Folder

  @valid_attrs %{open: true, position: 42, title: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Folder.changeset(%Folder{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Folder.changeset(%Folder{}, @invalid_attrs)
    refute changeset.valid?
  end
end
