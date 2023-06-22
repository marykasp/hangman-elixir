defmodule Browser1Web.Router do
  use Browser1Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {Browser1Web.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/hangman", Browser1Web do
    pipe_through :browser

    get "/", HangmanController, :index
    get "/:new", HangmanController, :new
  end

  # Other scopes may use custom stacks.
  # scope "/api", Browser1Web do
  #   pipe_through :api
  # end
end
