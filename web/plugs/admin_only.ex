defmodule Exagg.Plugs.AdminOnly do
  import Plug.Conn

  def init(_default) do
  end

  # Deny access if the current user is not an admin.
  def call(conn, _default) do
    case conn.assigns[:current_user].admin do
      true -> conn
      _ -> deny(conn)
    end
  end

  # Access denied, send an HTTP 403 response and do not continue
  defp deny(conn) do
    send_resp(conn, 403, "Access denied") |> halt
  end
end
