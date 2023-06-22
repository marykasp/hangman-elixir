defmodule Browser1Web.PageController do
  use Browser1Web, :controller

  # action - receiving incoming web request (conn = connection)
  def home(conn, _params) do
    # The home page is often custom made,
    # so skip the default app layout.
    render(conn, :home, layout: false)
  end
end
