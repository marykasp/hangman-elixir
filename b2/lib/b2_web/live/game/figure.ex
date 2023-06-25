defmodule B2Web.Live.Game.Figure do
  use B2Web, :live_component

  def mount(socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <h1>
      In Figure
    </h1>
    """
  end
end
