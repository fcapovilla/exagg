defmodule Exagg.User do
  use Exagg.Web, :model
  use Coherence.Schema

  schema "users" do
    field :username, :string
    field :admin, :boolean, default: false
    coherence_schema

    timestamps
  end

  @required_fields ~w(username admin)
  @optional_fields ~w()

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields ++ coherence_fields, @optional_fields)
    |> validate_coherence(params)
  end
end
