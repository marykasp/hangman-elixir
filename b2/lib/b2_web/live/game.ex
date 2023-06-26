defmodule B2Web.Live.Game do
  use B2Web, :live_view

  def mount(_params, _session, socket) do
    # create new hangman server process - starts individual game
    game = Hangman.new_game()
    # use process of game to get tally
    tally = Hangman.tally(game)

    # assign both to socket
    {:ok,
     socket
     |> assign(%{page_title: "Hangman", game: game, tally: tally})}
  end

  @doc """
  Liveview components are a good way of splitting a page into separate areas, each with its own substate and logic.
  """
  def render(assigns) do
    ~H"""
    <div class="game-holder" phx-window-keyup="make_move">
      <.live_component module={__MODULE__.Figure} id={1} tally={@tally} />
      <.live_component module={__MODULE__.Alphabet} id={2} tally={@tally} />
      <.live_component module={__MODULE__.WordSoFar} id={3} tally={@tally} />
    </div>
    """
  end

  def handle_event("make_move", %{"key" => key}, socket) do
    # make move based on key
    tally = Hangman.make_move(socket.assigns.game, key)

    {:noreply,
     socket
     |> assign(:tally, tally)}
  end
end
