defmodule Dictionary do
  @moduledoc """
  Documentation for `Dictionary`.
  Top level module is an API that delegates function calls
  """
  alias Dictionary.Runtime.Server

  @opaque t :: Server.t()

  @doc """
  Picks a random word from the word list
  """
  @spec random_word() :: String.t()
  defdelegate random_word(), to: Server
end
