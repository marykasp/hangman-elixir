defmodule Dictionary.Runtime.Server do
  @moduledoc """
  Start server agent that stores the word list state.
  """
  @type t :: pid()
  @me __MODULE__
  # tell elixir its a supervised agent
  use Agent
  alias Dictionary.Impl.WordList

  @doc """
  Initializes the state on the server - generates a list of words.
  """
  def start_link(_) do
    # generate process with a pid, initializes state, and register id of pid under name passed in
    Agent.start_link(&WordList.word_list/0, name: @me)
  end

  @doc """
  Uses state on pid to get random word from the list.
  Instead of passing in the pid of the process to the function, just use the registered name.
  """
  def random_word() do
    # crash the Agent
    # if :rand.uniform() < 0.33 do
    #   Agent.get(@me, fn _ -> exit(:boom) end)
    # end

    # look up name of pid under its registered name
    # even if pid is restarted/crashes (has a new id) the same name will still be applied to it
    # the WordList.random_word function is passed the state on the process (list of words)
    Agent.get(@me, &WordList.random_word/1)
  end
end
