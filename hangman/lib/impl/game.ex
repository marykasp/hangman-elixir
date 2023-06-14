defmodule Hangman.Impl.Game do
  @moduledoc """
  Contains game implementation.
  """

  # Set the type of each value in the struct (use the types set up in the Hangman module)
  @type t :: %Hangman.Impl.Game{
          turns_left: integer,
          game_state: Hangman.state(),
          letters: list(String.t()),
          used: MapSet.t(String.t())
        }

  # internal data structure that has same name as module
  defstruct(
    turns_left: 7,
    game_state: :initializing,
    letters: [],
    used: MapSet.new()
  )

  # returns a list of characters of a random word from the dictionary
  def new_game do
    new_game(Dictionary.random_word())
  end

  # returns a list of characters of word passed in as parameter
  def new_game(word) do
    %__MODULE__{
      letters: word |> String.codepoints()
    }
  end
end
