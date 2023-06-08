defmodule Dictionary do
  @moduledoc """
  Documentation for `Dictionary`.
  """

  @doc """
  Returns a list of words.

  ## Examples
  iex> Dictionary.word_list()

  """
  def word_list do
    File.read!("assets/words.txt")
    |> String.split(~r/\n/, trim: true)
  end

  @doc """
  Returns a random word from the word list.

  ## Examples
  iex> Dictionary.random_word
  """

  def random_word do
    Enum.random(word_list())
  end
end
