defmodule Exagg.Repo do
  use Ecto.Repo, otp_app: :exagg

  import Ecto.Query, only: [from: 2, order_by: 2, limit: 2, offset: 2]

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
          from i in query, where: field(i, ^String.to_existing_atom(col)) == ^val
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
            query |> order_by(desc: ^String.to_existing_atom(String.slice(val, 1..-1)))
          else
            query |> order_by(asc: ^String.to_existing_atom(val))
          end
        end)
    end
  end

  def paginate(query, conn = %Plug.Conn{}) do
    paginate(query, conn.params)
  end
  def paginate(query, params) do
    offset = String.to_integer(params["page_size"]) * (String.to_integer(params["page"])-1)
    limit = String.to_integer(params["page_size"])

    query |> limit(^limit) |> offset(^offset)
  end

  def for_current_user(query, conn) do
    user_id = conn.assigns[:current_user].id
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

  def update_ordering(type, data, scope, sort_column \\ :position)
  def update_ordering(type, changeset = %Ecto.Changeset{}, scope, sort_column) do
    import Ecto.Changeset

    # Detect scope change
    if Map.has_key?(changeset.changes, scope) do
      data = %{changeset.data|sort_column => 9999}
      {:ok, prev_scope_models} = update_ordering(type, data, scope, sort_column)

      data = %{data|sort_column => get_field(changeset, sort_column), scope => get_field(changeset, scope)}
      {:ok, new_scope_models} = update_ordering(type, data, scope, sort_column)

      {:ok, prev_scope_models ++ new_scope_models}
    else
      data = %{changeset.data|sort_column => get_field(changeset, sort_column)}
      update_ordering(type, data, scope, sort_column)
    end
  end
  def update_ordering(type, data, scope, sort_column) do
    transaction fn ->
      list =
        from(i in type,
        where: field(i, ^scope) == ^Map.get(data, scope),
        where: i.id != ^data.id,
        order_by: field(i, ^sort_column))
        |> all

      {changesets, _} = Enum.reduce(list, {[], 1}, fn val, {acc, pos} ->
        acc = acc ++ [if(pos < Map.get(data, sort_column)) do
          val |> type.changeset(%{sort_column => pos})
        else
          val |> type.changeset(%{sort_column => pos+1})
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
