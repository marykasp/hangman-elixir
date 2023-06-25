defmodule B2Web.Live.Game do
  use B2Web, :live_view

  def mount(_params, _session, socket) do
    game = Hangman.new_game()
    tally = Hangman.tally(game)

    {:ok,
     socket
     |> assign(%{game: game, tally: tally})}
  end

  def render(assigns) do
    ~H"""
    <div class="game-holder">
      <.live_component module={__MODULE__.Figure} id={1} tally={@tally} />
      <.live_component module={__MODULE__.Alphabet} id={2} tally={@tally} />
      <.live_component module={__MODULE__.WordSoFar} id={3} tally={@tally} />
    </div>
    """
  end
end
