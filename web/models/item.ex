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
    has_many :medias, Exagg.Media, on_replace: :delete

    timestamps
  end

  @required_fields ~w(guid read favorite)
  @optional_fields ~w(title url content orig_feed_title date user_id feed_id)

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> cast_medias(params)
    |> truncate(:guid, 255)
    |> ignore_single_change(:date)
    |> ignore_nil_change(:date)
    |> default(:date, Ecto.DateTime.utc)
  end

  # Cast medias only if the medias param was provided and if medias changed
  defp cast_medias(changeset, params) do
    if params[:medias] do
      # Detect changes
      case changeset.data.medias do
        %Ecto.Association.NotLoaded{} -> cast_assoc(changeset, :medias, [])
        _ ->
          old = changeset.data.medias |> Enum.map(&Map.take(&1, [:type, :url]))
          new = params.medias |> Enum.map(&Map.take(&1, [:type, :url]))
          if old != new do
            cast_assoc(changeset, :medias, [])
          else
            changeset
          end
      end
    else
      changeset
    end
  end

  # Truncate the field to "size" characters
  defp truncate(changeset, field, size) do
    value = get_field(changeset, field)
    if String.length(value) > size do
      put_change(changeset, field, String.slice(value, 1..size))
    else
      changeset
    end
  end

  # Ignore changes to nil for the specified field
  defp ignore_nil_change(changeset, field) do
    if is_nil(get_change(changeset, field, :empty)) do
      delete_change(changeset, field)
    else
      changeset
    end
  end

  # Ignore changeset if only the specified field changed
  defp ignore_single_change(changeset, field) do
    if Map.keys(changeset.changes) == [field] do
      delete_change(changeset, field)
    else
      changeset
    end
  end

  # Force a default value for the field
  defp default(changeset, field, value) do
    if is_nil(get_field(changeset, field)) do
      put_change(changeset, field, value)
    else
      changeset
    end
  end
end
