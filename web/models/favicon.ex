defmodule Exagg.Favicon do
  use Exagg.Web, :model

  schema "favicons" do
    field :host, :string
    field :data, :string
    has_many :feeds, Exagg.Feed

    timestamps
  end

  @required_fields ~w(host data)
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
