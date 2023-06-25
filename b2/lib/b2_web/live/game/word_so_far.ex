defmodule B2Web.Live.Game.WordSoFar do
  use B2Web, :live_component

  def mount(socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <h1>word_so_far</h1>
    """
  end
end
