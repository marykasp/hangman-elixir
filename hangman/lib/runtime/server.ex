defmodule Hangman.Runtime.Server do
  use GenServer
  alias Hangman.Impl.Game

  ### Client process
  def start_link do
    # kick off a server - creates a brand new process - callsback to init function
    GenServer.start_link(__MODULE__, nil)
  end

  ### Server process
  def init(_) do
    # return a tuple including the state of the game
    {:ok, Game.new_game()}
  end

  # make a move - handle call
  def handle_call({:make_move, guess}, _form, game) do
    {updated_game, tally} = Game.make_move(game, guess)
    # returns value, updated state
    {:reply, tally, updated_game}
  end

  def handle_call({:tally}, _from, game) do
    # state does not change
    {:reply, Game.tally(game), game}
  end
end
