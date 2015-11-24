defmodule Exagg.Plugs.JsonApiToEcto do
  import Plug.Conn

  def init(key) do
    key
  end

  # Convert JSON-API data into parameters usable by Ecto.
  def call(conn, key) do
    new_data =
      Enum.reduce(conn.params[key]["relationships"], %{}, fn {name, value}, acc ->
        Map.put(acc, name <> "_id", String.to_integer(value["data"]["id"]))
      end)
      |> Map.put("id", String.to_integer(conn.params[key]["id"]))
      |> Map.merge(conn.params[key]["attributes"])

    put_in(conn.params[key], new_data)
  end
end
