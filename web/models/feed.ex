defmodule Exagg.Feed do
  use Exagg.Web, :model

  schema "feeds" do
    field :title, :string
    field :url, :string
    field :last_sync, Ecto.DateTime
    field :update_frequency, :integer
    field :auto_frequency, :boolean
    field :unread_count, :integer
    field :sync_status, :string
    field :position, :integer
    belongs_to :user, Exagg.User
    belongs_to :folder, Exagg.Folder
    belongs_to :favicon, Exagg.Favicon
    has_many :items, Exagg.Item

    timestamps
  end

  @required_fields ~w(url)
  @optional_fields ~w(title sync_status position last_sync update_frequency auto_frequency unread_count folder_id user_id favicon_id)

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
