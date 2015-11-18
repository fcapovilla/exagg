defmodule Exagg.Feed do
  use Exagg.Web, :model

  schema "feeds" do
    field :title, :string
    field :url, :string
    field :last_sync, Ecto.DateTime
    field :unread_count, :integer
    field :sync_status, :string
    field :favicon, :binary
    field :position, :integer
    belongs_to :user, Exagg.User
    belongs_to :folder, Exagg.Folder
    has_many :items, Exagg.Item

    timestamps
  end

  @required_fields ~w(title url last_sync unread_count position)
  @optional_fields ~w(sync_status favicon)

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
