defmodule TextClient.Impl.Player do
  @type game :: Hangman.game()
  @type tally :: Hangman.tally()
  @type state :: {game, tally}

  @spec start() :: :ok
  def start() do
    game = Hangman.new_game()
    tally = Hangman.tally(game)
    interact({game, tally})
  end

  @spec interact(state) :: :ok

  def interact({_game, %{game_state: :won}}) do
    IO.puts("Congratulatins! You won!")
  end

  def interact({_game, %{game_state: :lost} = tally}) do
    IO.puts("Sorry, you lost.... the word was #{tally.letters |> Enum.join()}")
  end

  def interact({game, tally}) do
    # take in state and give feedback
    IO.puts(feedback_for(tally))
    # display the current word
    IO.puts(current_word(tally))
    # get the next guess
    # make move based on guess
    Hangman.make_move(game, get_guess())
    |> interact()
  end

  @doc """
  Function that checks the game state on the tally map and pattern matches for different sentences to return to console based
  on the context.
  """
  def feedback_for(%{game_state: :initializing} = tally) do
    "Welcome! I'm thinking of a #{tally.letters |> length} letter word"
  end

  def feedback_for(%{game_state: :good_guess}), do: "Good guess!"

  def feedback_for(%{game_state: :bad_guess}), do: "Sorry, that letter is not in the word."

  def feedback_for(%{game_state: :already_used}), do: "You already used that letter."

  def current_word(tally) do
    formatted_turns_text = IO.ANSI.format([:green, " turns left: "])
    formatted_turns = IO.ANSI.format([:blue, tally.turns_left |> to_string])
    formatted_guesses_text = IO.ANSI.format([:green, " guesses: "])
    formatted_guesses = IO.ANSI.format([:magenta, tally.used |> Enum.join(", ")])

    [
      "Word so far: ",
      IO.ANSI.format([:yellow, tally.letters |> Enum.join(" ")]),
      formatted_turns_text,
      formatted_turns,
      formatted_guesses_text,
      formatted_guesses
    ]
  end

  def get_guess() do
    IO.gets("Next letter: ")
    # trims the new line at end of prompt
    |> String.trim()
    |> String.downcase()
  end
end
