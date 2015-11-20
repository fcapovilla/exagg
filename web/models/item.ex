defmodule Exagg.Item do
  use Exagg.Web, :model

  schema "items" do
    field :title, :string
    field :url, :string
    field :guid, :string
    field :content, :string
    field :read, :boolean, default: false
    field :favorite, :boolean, default: false
    field :date, Ecto.DateTime
    field :orig_feed_title, :string
    belongs_to :user, Exagg.User
    belongs_to :feed, Exagg.Feed
    has_many :medias, Exagg.Media, on_delete: :fetch_and_delete

    timestamps
  end

  @required_fields ~w(title url guid read favorite date)
  @optional_fields ~w(content orig_feed_title)

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
