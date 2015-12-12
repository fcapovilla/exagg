defmodule Exagg.Plugs.TokenAuth do
  import Plug.Conn

  def init(_default) do
  end

  # Prevent access without a valid Bearer token.
  def call(conn, _default) do
    auth = conn |> get_req_header("authorization")
    if Enum.empty? auth do
      deny(conn)
    else
      [type, token] = hd(auth) |> String.split(" ")

      if type == "Bearer" do
        case Phoenix.Token.verify(conn, "user", token, max_age: 1209600) do
          {:ok, user_id} -> authorize(conn, user_id)
          {:error, _} -> deny(conn)
        end
      else
        deny(conn)
      end
    end
  end

  # Access authorized, add the current user_id to the conn struct
  defp authorize(conn, user_id) do
    assign(conn, :user_id, user_id)
  end

  # Access denied, send an HTTP 403 response and do not continue
  defp deny(conn) do
    send_resp(conn, 403, "Access denied") |> halt
  end
end
