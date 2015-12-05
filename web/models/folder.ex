defmodule Exagg.Folder do
  use Exagg.Web, :model

  schema "folders" do
    field :title, :string
    field :open, :boolean, default: true
    field :position, :integer
    belongs_to :user, Exagg.User
    has_many :feeds, Exagg.Feed, on_delete: :fetch_and_delete

    timestamps
  end

  @required_fields ~w(title open)
  @optional_fields ~w(position user_id)

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
