defmodule Exagg.Router do
  use Exagg.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json-api", "json"]
  end

  scope "/api", Exagg do
    pipe_through :api

    resources "/folders", FolderController do
      get "/feeds", FeedController, :index
      get "/items", ItemController, :index
    end
    resources "/feeds", FeedController do
      get "/items", ItemController, :index
    end
    resources "/items", ItemController
    resources "/users", UserController

    post "/opml/upload", SettingsController, :opml_upload
    post "/favorites/upload", SettingsController, :favorites_upload
    get "/sync", SettingsController, :sync

    post "/token-auth", UserController, :token_auth
    post "/token-refresh", UserController, :token_refresh
  end

  get "/favicons/:id", Exagg.FaviconController, :show

  scope "/", Exagg do
    pipe_through :browser # Use the default browser stack

    get "/*path", PageController, :index
  end
end
