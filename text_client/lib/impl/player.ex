defmodule TextClient.Impl.Player do
  @type game :: Hangman.game()
  @type tally :: Hangman.tally()
  @typep state :: {game, tally}

  @spec start() :: :ok
  def start() do
    game = Hangman.new_game()
    tally = Hangman.tally(game)
    interact({game, tally})
  end

  @spec interact(state) :: :ok

  def interact(_game, %{game_state: :won}) do
    IO.puts("Congratulatins! You won!")
  end

  def interact(game, %{game_state: :lost}) do
    IO.puts("Sorry, you lost.... the word was #{game.letters |> Enum.join()}")
  end

  def interact({game, tally}) do
    # take in state and give feedback
    IO.puts(feedback_for(tally))
    # display the current word
    # get the next guess
    # make move based on guess
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
end
