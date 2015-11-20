defmodule Exagg.Media do
  use Exagg.Web, :model

  schema "medias" do
    field :type, :string
    field :url, :string

    belongs_to :item, Exagg.Item

    timestamps
  end

  @required_fields ~w(type url)
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
