defmodule Browser1Web.HangmanController do
  use Browser1Web, :controller

  # render the hangman game page
  def index(conn, _params) do
    render(conn, :index)
  end

  def new(conn, _params) do
    game = Hangman.new_game()
    # server sends token to browser about session
    # next time request is sent will include that cookie data, server will extract it, and convert back to session form
    # returns a new connection that has game in session
    conn
    |> put_session(:game, game)
    |> redirect(to: ~p"/hangman/current")
  end

  def update(conn, params) do
    guess = params["guess"]

    conn
    # return pid of game which is then passed to make_move on GenServer call to return tally
    |> get_session(:game)
    |> Hangman.make_move(guess)

    redirect(conn, to: ~p"/hangman/current")
  end

  # show a new game or show status of previous game
  def show(conn, _params) do
    # get updated tally using GenServer call tally - returns the tally of game
    tally =
      conn
      |> get_session(:game)
      |> Hangman.tally()

    render(conn, :new, tally: tally)
  end
end
