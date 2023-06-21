defmodule Browser1Web.HangmanController do
  use Browser1Web, :controller

  def index(conn, _params) do
    render(conn, :index)
  end
end
