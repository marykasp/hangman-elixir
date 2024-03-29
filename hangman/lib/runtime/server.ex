defmodule Hangman.Runtime.Server do
  use GenServer
  alias Hangman.Impl.Game
  alias Hangman.Runtime.Watchdog

  @type t :: pid

  # 1 hour
  @idle_timeout 1 * 60 * 60 * 1000

  ### Client process
  # start_link is being done by supervisor so expects a dummy paramter
  def start_link(_) do
    # kick off a server - creates a brand new process - callsback to init function
    GenServer.start_link(__MODULE__, nil)
  end

  ### Server process
  def init(_) do
    watcher = Watchdog.start(@idle_timeout)
    # return a tuple including the state of the game
    {:ok, {Game.new_game(), watcher}}
  end

  # handle calls - request from client to make a move, get tally
  def handle_call({:make_move, guess}, _form, {game, watcher}) do
    Watchdog.im_alive(watcher)
    {updated_game, tally} = Game.make_move(game, guess)
    # atom reply, returned value (tally), updated state
    {:reply, tally, {updated_game, watcher}}
  end

  def handle_call({:tally}, _from, {game, watcher}) do
    Watchdog.im_alive(watcher)
    # state does not change
    {:reply, Game.tally(game), {game, watcher}}
  end
end
