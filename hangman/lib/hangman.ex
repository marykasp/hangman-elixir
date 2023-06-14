defmodule Hangman do
  alias Hangman.Impl.Game
  alias Hangman.Type

  # defines type whose contents are not usuable out of this module (keep out of internal state)
  @opaque game :: Game.t()

  # returns a game token - represents the state of the game
  @spec new_game() :: game
  # implementation of new game function is in Game module
  # defdelegate defines a function that delegates to antoher module
  defdelegate new_game, to: Game

  @spec make_move(game, String.t()) :: {game, Type.tally()}
  # returns a new game state and a tally
  def make_move(_game, _guess) do
  end
end
