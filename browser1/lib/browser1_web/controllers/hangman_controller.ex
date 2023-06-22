defmodule Browser1Web.HangmanController do
  use Browser1Web, :controller

  def index(conn, _params) do
    render(conn, :index)
  end

  def new(conn, _params) do
    game = Hangman.new_game()
    tally = Hangman.tally(game)
    # store game in session
    put_session(conn, :game, game)
    render(conn, :new, tally: tally)
  end
end
