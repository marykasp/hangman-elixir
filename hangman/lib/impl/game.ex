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

  def new_game do
    %Hangman.Impl.Game{
      letters: Dictionary.random_word() |> String.codepoints()
    }
  end
end
