defmodule Dictionary.Runtime.Server do
  @moduledoc """
  Start server agent that stores the word list state.
  """

  @type t :: pid()
  @me __MODULE__
  alias Dictionary.Impl.WordList

  @doc """
  Initializes the state on the server - generates a list of words.
  """
  def start_link() do
    # generate process with a pid and register id of pid under name passed in
    Agent.start_link(&WordList.word_list/0, name: @me)
  end

  @doc """
  Uses state on pid to get random word from the list
  """
  def random_word() do
    # look up name of pid under the alias name
    Agent.get(@me, &WordList.random_word/1)
  end
end
