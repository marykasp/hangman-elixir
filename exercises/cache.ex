defmodule Cache do
  @moduledoc """
  Implement a map for key-value cache. State is stored in Agent, in the form of a map.

  The function `lookup` tries to look the value up in the cache,  and then calls `complete_if_not_found`
  This takes two forms - if there was no value in the cache, it calls the function passed in by the client to supply it.
  Updating the cache at the same time.

  Otherwise, it simply returns the cached value.
  """

  @doc """
  Start the cache in the server, run the supplied function, then stop the cache.

  """

  def run(body) do
    {:ok, pid} = Agent.start_link(fn -> %{0 => 0, 1 => 1} end)
    result = body.(pid)
    Agent.stop(pid)
    result
  end

  def lookup(cache, n, if_not_found) do
    Agent.get(cache, fn map -> map[n] end)
    |> complete_if_not_found(cache, n, if_not_found)
  end

  def complete_if_not_found(nil, cache, n, if_not_found) do
    if_not_found.()
    |> set(cache, n)
  end

  def set(val, cache, n) do
    Agent.get_and_update(cache, fn map ->
      {val, Map.put(map, n, val)}
    end)
  end
end
