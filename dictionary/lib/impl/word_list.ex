defmodule Dictionary.Impl.WordList do
  @type t :: list(String.t())

  @spec word_list() :: t
  def word_list do
    "assets/words.txt"
    |> File.read!()
    |> String.split(~r/\n/, trim: true)
  end

  @doc """
  Returns a random word from the word list.

  ## Examples
  iex> Dictionary.random_word
  """

  @spec random_word(t) :: String.t()
  def random_word(word_list) do
    word_list
    |> Enum.random()
  end
end
