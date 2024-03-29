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
  @doc """
  Starts a new game by generating a random word from the list of words on the server state.
  Then creates a new game struct with the letters of that word stored in a list of strings on letters.
  """
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
  Returns a tuple {game, tally} - tally contains same state as game with letters including only those guessed correctly

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
    # add guess to used, check if guess is in letters of word
    %{game | used: MapSet.put(game.used, guess)}
    |> score_guess(Enum.member?(game.letters, guess))
  end

  #####################################################################

  defp score_guess(game, _good_guess = true) do
    # guessed all letters? -> :won | :good_guess
    # checks if the characters in letters match characters in game used - returns boolean
    # use another function that takes that boolean and returns an atom game state
    new_state = maybe_won(MapSet.subset?(MapSet.new(game.letters), game.used))
    %{game | game_state: new_state}
  end

  defp score_guess(%{turns_left: 1} = game, _bad_guess) do
    # turns_left == 1 -> lost | decrement turns_left, :bad_guess
    %{game | game_state: :lost, turns_left: 0}
  end

  defp score_guess(game, _bad_guess) do
    # turns_left == 1 -> lost | decrement turns_left, :bad_guess
    %{game | game_state: :bad_guess, turns_left: game.turns_left - 1}
  end

  #####################################################################

  ## game is updated with make_move, accept_guess, and score_guess - uses game state
  # tally letters track which letters that were correct user guessed
  def tally(game) do
    %{
      turns_left: game.turns_left,
      game_state: game.game_state,
      letters: reveal_guessed_letters(game),
      used: game.used |> MapSet.to_list() |> Enum.sort()
    }
  end

  @doc """
  Will take in the game struct, if the game is lost will just reveal the letters of the word from the
  game letters list.

  Otherwise will update the tally struct letters to include the letter if guessed or to include an _ if not
  already guessed. Iterates over the game.letters, checks if the letter is a member of the used mapset, if
  so then will reveal the letter if not then will add _
  """

  def reveal_guessed_letters(%{game_state: :lost} = game) do
    game.letters
  end

  def reveal_guessed_letters(game) do
    game.letters
    |> Enum.map(fn letter ->
      # check if already guessed the letter
      MapSet.member?(game.used, letter)
      # if did guess the letter in the word then return letter if not return _ to add to list
      |> maybe_reveal(letter)
    end)
  end

  defp maybe_reveal(true, letter), do: letter
  defp maybe_reveal(_, _letter), do: "_"

  defp return_with_tally(game) do
    {game, tally(game)}
  end

  defp maybe_won(true), do: :won
  defp maybe_won(_), do: :good_guess
end
