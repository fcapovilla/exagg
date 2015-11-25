defmodule Exagg.Plugs.JsonApiToEcto do
  import Plug.Conn

  def init(key) do
    key
  end

  # Convert JSON-API data into parameters usable by Ecto.
  def call(conn, key) do
    new_data = case conn.params[key] do
      %{"relationships" => relationships} ->
        Enum.reduce(conn.params[key]["relationships"], %{}, fn {name, value}, acc ->
          case value["data"] do
            %{"id" => id} -> Map.put(acc, name <> "_id", String.to_integer(id))
            _ -> acc
          end
        end)
        |> Map.merge(conn.params[key]["attributes"])
      _ ->
        conn.params[key]["attributes"]
    end

    if conn.params[key]["id"] do
      new_data = new_data |> Map.put("id", String.to_integer(conn.params[key]["id"]))
    end

    put_in(conn.params[key], new_data)
  end
end
