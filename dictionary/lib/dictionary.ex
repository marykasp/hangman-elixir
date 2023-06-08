defmodule Dictionary do
  @moduledoc """
  Documentation for `Dictionary`.
  """

  # module attribute created at compile time
  @word_list "assets/words.txt"
             |> File.read!()
             |> String.split(~r/\n/, trim: true)

  @doc """
  Returns a random word from the word list.

  ## Examples
  iex> Dictionary.random_word
  """

  def random_word do
    @word_list
    |> Enum.random()
  end
end
