defmodule Exagg.User do
  use Exagg.Web, :model

  schema "users" do
    field :username, :string
    field :password, :string
    field :admin, :boolean, default: false

    timestamps
  end

  @required_fields ~w(username password admin)
  @optional_fields ~w()

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
  end
end
