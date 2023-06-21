defmodule Hangman do
  alias Hangman.Runtime.Server
  alias Hangman.Type

  # defines type whose contents are not usuable out of this module (keep out of internal state)
  @opaque game :: Server.t()
  @type tally :: Type.tally()

  # returns a game token - represents the state of the game
  @spec new_game() :: game
  def new_game do
    {:ok, pid} = Server.start_link()
    pid
  end

  # returns a new game state and a tally
  @spec make_move(game, String.t()) :: {game, tally}
  def make_move(game, guess) do
    GenServer.call(game, {:make_move, guess})
  end

  @spec tally(game) :: tally
  def tally(game) do
    GenServer.call(game, {:tally})
  end
end
