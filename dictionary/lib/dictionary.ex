defmodule Dictionary do
  @moduledoc """
  Documentation for `Dictionary`.
  Top level module is an API that delegates function calls
  """
  alias Dictionary.Runtime.Server

  @opaque t :: Server.t()

  @doc """
  Reads the words in the word.txt file and generates a list of those words.
  """
  @spec start_link() :: {:ok, t}
  defdelegate start_link(), to: Server

  @doc """
  Picks a random word from the word list
  """
  @spec random_word(t) :: String.t()
  defdelegate random_word(word_list), to: Server
end
