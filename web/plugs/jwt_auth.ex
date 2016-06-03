defmodule Exagg.Plugs.JWTAuth do
  import Plug.Conn
  import Joken

  alias Exagg.User

  def init(options), do: options

  # Prevent access without a valid JWT Bearer token.
  def call(conn, options) do
    auth = conn |> get_req_header("authorization")
    if Enum.empty? auth do
      deny(conn)
    else
      [type, token] = hd(auth) |> String.split(" ")

      if type == "Bearer" do
        jwt =
          token
          |> token()
          |> with_signer(hs256(conn.secret_key_base))
          |> with_validation("iat", &(&1 <= current_time))
          |> with_validation("nbf", &(&1 < current_time))
          |> with_validation("exp", &(&1 > current_time))

        case verify!(jwt) do
          {:ok, claims} -> authorize(conn, claims["user"])
          {:error, _} -> deny(conn)
        end
      else
        deny(conn)
      end
    end
  end

  # Access authorized, add the current user data to the conn struct
  defp authorize(conn, user) do
    assign(conn, :user, user)
  end

  # Access denied, send an HTTP 403 response and do not continue
  defp deny(conn) do
    send_resp(conn, 403, ~s({"error":"Access denied"})) |> halt
  end
end
