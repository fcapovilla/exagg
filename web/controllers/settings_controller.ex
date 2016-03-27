defmodule Exagg.SettingsController do
  use Exagg.Web, :controller

  plug Exagg.Plugs.JWTAuth

  def favorites_upload(conn, %{"file" => file}) do
    case file.content_type do
      "application/json" ->
        Exagg.JSONFavoriteImporter.import(file, conn)
        redirect conn, to: folder_path(conn, :index)
      _ ->
        json(conn, %{error: "Invalid JSON file."})
    end
  end

  def opml_upload(conn, %{"file" => file}) do
    case file.content_type do
      "text/x-opml+xml" ->
        Exagg.OPMLImporter.import(file, conn)
        redirect conn, to: folder_path(conn, :index)
      _ ->
        json(conn, %{error: "Invalid OPML file."})
    end
  end

  def items_upload(conn, %{"file" => file}) do
    case file.content_type do
      "application/json" ->
        Exagg.JSONItemImporter.import(file, conn)
        redirect conn, to: folder_path(conn, :index)
      _ ->
        json(conn, %{error: "Invalid JSON file."})
    end
  end

  def sync(conn, _params) do
    Exagg.Syncer.sync_all
    redirect conn, to: folder_path(conn, :index)
  end
end
