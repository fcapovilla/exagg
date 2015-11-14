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
    plug :accepts, ["json"]
  end

  scope "/", Exagg do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
    post "/opml_upload", PageController, :opml_upload

    resources "/users", UserController
  end

  scope "/api", Exagg do
    pipe_through :api

    resources "/folders", FolderController
    resources "/feeds", FeedController
    resources "/items", ItemController
  end
end
