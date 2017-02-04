defmodule Exagg.Router do
  use Exagg.Web, :router
  use Coherence.Router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug Coherence.Authentication.Session
  end

  pipeline :protected do
    plug :accepts, ["html", "json-api", "json"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug Coherence.Authentication.Session, protected: true
  end

  scope "/" do
    pipe_through :browser
    coherence_routes
  end

  scope "/" do
    pipe_through :protected
    coherence_routes :protected
  end

  scope "/api", Exagg do
    pipe_through :protected

    post "/opml/upload", SettingsController, :opml_upload
    post "/favorites/upload", SettingsController, :favorites_upload
    post "/items/upload", SettingsController, :items_upload
    get "/sync", SettingsController, :sync

    resources "/folders", FolderController do
      get "/feeds", FeedController, :index
      get "/items", ItemController, :index
    end
    resources "/feeds", FeedController do
      get "/items", ItemController, :index
    end
    resources "/items", ItemController
    resources "/users", UserController
  end

  get "/favicons/:id", Exagg.FaviconController, :show

  scope "/", Exagg do
    pipe_through :browser

    get "/*path", PageController, :index
  end
end
