defmodule B2Web.Live.Game.WordSoFar do
  use B2Web, :live_component

  @states %{
    initializing: "Type or click on your first letter guess.",
    already_used: "You already picked that letter!",
    bad_guess: "That letter is not in the word.",
    good_guess: "Good guess!",
    lost: "Sorry, you lost...",
    won: "You won!"
  }

  def mount(socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div>
      <div class="game-state">
        <%= state_name(@tally.game_state) %>
      </div>

      <div class="letters flex items-center space-x-5 text-2xl w-[1em] text-violet-500">
        <%= for letter <- @tally.letters do %>
          <div class={"one-letter #{if letter != "_", do: "correct text-emerald-500"}"}>
            <%= letter %>
          </div>
        <% end %>
      </div>
    </div>
    """
  end

  def state_name(state) do
    # map state to a string
    @states[state] || "Unknown state"
  end
end
