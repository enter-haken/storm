defmodule StormWeb.Router do
  use StormWeb, :router

  import StormWeb.SessionPlug

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {StormWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :init_session
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", StormWeb do
    pipe_through :browser

    live "/", IndexLive, :index
    live "/collection/:id", CollectionLive, :index
    live "/top", TopLive, :index
  end
end
