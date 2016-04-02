defmodule Exagg.Repo do
  use Ecto.Repo, otp_app: :exagg
  use Scrivener, page_size: 20

  import Ecto.Query, only: [from: 1, from: 2, order_by: 2]

  def filter(query, conn = %Plug.Conn{}) do
    query |> filter(conn.params) |> for_current_user(conn)
  end
  def filter(query, params) do
    case params["filter"] do
      nil -> query
      filters ->
        filters
        |> Enum.reject(fn {_col, val} -> val == "" end)
        |> Enum.reduce(query, fn {col, val}, query ->
          from i in query, where: field(i, ^String.to_atom(col)) == ^val
        end)
    end
  end

  def sort(query, conn = %Plug.Conn{}) do
    sort(query, conn.params)
  end
  def sort(query, params) do
    case params["sort"] do
      nil -> query
      sort ->
        sort
        |> String.split(",")
        |> Enum.reduce(query, fn val, query ->
          if String.at(val, 0) == "-" do
            query |> order_by(desc: ^String.to_atom(String.slice(val, 1..-1)))
          else
            query |> order_by(asc: ^String.to_atom(val))
          end
        end)
    end
  end

  def for_current_user(query, conn) do
    user_id = conn.assigns[:user]["id"]
    if user_id do
      from i in query, where: i.user_id == ^user_id
    else
      query
    end
  end

  def update_unread_count(feed = %Exagg.Feed{}, changes \\ %{}) do
    transaction fn ->
      count = one(from i in Exagg.Item, where: i.feed_id == ^feed.id and i.read == false, select: count(i.id))
      feed |> Exagg.Feed.changeset(Dict.put(changes, :unread_count, count)) |> update!
    end
  end

  def update_position(type, object, scope, sort_column \\ :position) do
    transaction fn ->
      list =
        from(i in type,
        where: field(i, ^scope) == ^Map.get(object, scope),
        where: i.id != ^object.id,
        order_by: field(i, ^sort_column))
        |> all

      {changesets, _} = Enum.reduce(list, {[], 1}, fn val, {acc, pos} ->
        acc = acc ++ [if(pos < object.position) do
          val |> type.changeset(%{position: pos})
        else
          val |> type.changeset(%{position: pos+1})
        end]
        {acc, pos+1}
      end)

      Enum.map(changesets, fn(changeset) ->
        {:ok, model} = update(changeset)
        model
      end)
    end
  end
end
