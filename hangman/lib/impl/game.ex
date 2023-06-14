defmodule Hangman.Impl.Game do
  @moduledoc """
  Contains game implementation.
  """
  alias Hangman.Type

  # Set the type of each value in the struct (use the types set up in the Hangman module)
  @type t :: %Hangman.Impl.Game{
          turns_left: integer,
          game_state: Type.state(),
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

  #####################################################################
  # returns a list of characters of a random word from the dictionary
  @spec new_game() :: t
  def new_game do
    new_game(Dictionary.random_word())
  end

  # returns a list of characters of word passed in as parameter
  @spec new_game(String.t()) :: t
  def new_game(word) do
    %__MODULE__{
      letters: word |> String.codepoints()
    }
  end

  #####################################################################

  @doc """
  Make move will have pattern matching functions to match on the state of game.
  Returns a tuple {game, tally}

  :won - returns game and a new tally map (used letters are converted from MapSet to list)
  :lost - returns game and a new tally map
  If not :won or :lost -
  Check if guess is in the used game struct MapSet, if true then change game state, if not add to
  MapSet
  """
  @spec make_move(t, String.t()) :: {t, Type.tally()}
  def make_move(%{game_state: state} = game, _guess) when state in [:won, :lost] do
    game
    |> return_with_tally()
  end

  def make_move(game, guess) do
    # check if the guess is in the MapSet - returns boolean
    accept_guess(game, guess, MapSet.member?(game.used, guess))
    |> return_with_tally()
  end

  #####################################################################
  defp accept_guess(game, _guess, _already_used = true) do
    %{game | game_state: :already_used}
  end

  defp accept_guess(game, guess, _already_used) do
    # add guess to used
    %{game | used: MapSet.put(game.used, guess)}
  end

  #####################################################################

  defp tally(game) do
    %{
      turns_left: game.turns_left,
      game_state: game.game_state,
      letters: [],
      used: game.used |> MapSet.to_list() |> Enum.sort()
    }
  end

  defp return_with_tally(game) do
    {game, tally(game)}
  end
end
