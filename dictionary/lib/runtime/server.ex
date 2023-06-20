defmodule Dictionary.Runtime.Server do
  @moduledoc """
  Start server agent that stores the word list state.
  """

  @type t :: pid()
  alias Dictionary.Impl.WordList

  def start_link() do
    Agent.start_link(&WordList.word_list/0)
  end

  def random_word(pid) do
    Agent.get(pid, &WordList.random_word/1)
  end
end
