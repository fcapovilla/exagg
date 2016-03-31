defmodule Exagg.Repo do
  use Ecto.Repo, otp_app: :exagg
  use Scrivener, page_size: 20

  import Ecto.Query, only: [from: 1, from: 2]

  def filter(query, conn = %Plug.Conn{}) do
    query |> filter(conn.params) |> for_current_user(conn)
  end
  def filter(query, params) do
    case params["filter"] do
      nil -> query
      filters ->
        filters
        |> Enum.reject(fn {col, val} -> val == "" end)
        |> Enum.reduce(query, fn {col, val}, query ->
          from i in query, where: field(i, ^String.to_atom(col)) == ^val
        end)
    end
  end

  def order(query, conn = %Plug.Conn{}) do
    order(query, conn.params)
  end
  def order(query, _params) do
    from i in query, order_by: [desc: i.date, desc: i.id]
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
end
