defmodule Exagg.FaviconTest do
  use Exagg.ModelCase

  alias Exagg.Favicon

  @valid_attrs %{data: "some content", url: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Favicon.changeset(%Favicon{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Favicon.changeset(%Favicon{}, @invalid_attrs)
    refute changeset.valid?
  end
end
