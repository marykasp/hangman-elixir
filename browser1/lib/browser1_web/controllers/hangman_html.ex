defmodule Browser1Web.HangmanHTML do
  use Browser1Web, :html

  # status fields for the state of the game
  @status_fields %{
    initializing: {"intializing", "Guess the word"},
    won: {"won", "You won!"},
    lost: {"lost", "Sorry, you lost"},
    already_used: {"already_used", "You already used that letter"},
    good_guess: {"good_guess", "Good guess!"},
    bad_guess: {"bad_guess", "Sorry, that's a bad guess"}
  }
  def move_status(status) do
    # retrieve class and message from status_fields map
    {class, message} = @status_fields[status]
    "<div class='mb-2 px-4 #{status_color(status)} #{class}'>#{message}</div>"
  end

  def status_color(status) do
    case status do
      :initializing -> "text-sky-500"
      :good_guess -> "text-emerald-500"
      :bad_guess -> "text-rose-500"
      :won -> "text-green-500 font-bold"
      :lost -> "text-red-500 font-bold"
      :already_used -> "text-purple-500"
      _ -> "text-gray-500"
    end
  end

  def continue_or_try_again(%{assigns: assigns} = _conn, status) when status in [:won, :lost] do
    ~H"""
    <.link href={~p'/hangman/new'} class="ml-4 py-2 px-4 bg-rose-500 text-sm text-white rounded-md ">
      Try again
    </.link>
    """
  end

  def continue_or_try_again(%{assigns: assigns} = conn, _status) do
    ~H"""
    <.form
      :let={f}
      for={conn}
      action="update"
      as={:make_move}
      method="put"
      class="inline-flex items-center space-x-4  px-4"
    >
      <.input field={{f, :guess}} name="guess" value="" extend_class="max-w-[4rem] text-md font-bold" />

      <.button type="submit" class="mt-[0.3rem] text-xs">Make next guess</.button>
    </.form>
    """
  end

  def figure_for(0) do
    ~s{
      ┌───┐
      │   │
      O   │
     /|\\  │
     / \\  │
          │
    ══════╧══
    }
  end

  def figure_for(1) do
    ~s{
      ┌───┐
      │   │
      O   │
     /|\\  │
     /    │
          │
    ══════╧══
    }
  end

  def figure_for(2) do
    ~s{
    ┌───┐
    │   │
    O   │
   /|\  │
        │
        │
  ══════╧══
}
  end

  def figure_for(3) do
    ~s{
    ┌───┐
    │   │
    O   │
   /|   │
        │
        │
  ══════╧══
}
  end

  def figure_for(4) do
    ~s{
    ┌───┐
    │   │
    O   │
    |   │
        │
        │
  ══════╧══
}
  end

  def figure_for(5) do
    ~s{
    ┌───┐
    │   │
    O   │
        │
        │
        │
  ══════╧══
}
  end

  def figure_for(6) do
    ~s{
    ┌───┐
    │   │
        │
        │
        │
        │
  ══════╧══
}
  end

  def figure_for(7) do
    ~s{
    ┌───┐
        │
        │
        │
        │
        │
  ══════╧══
}
  end

  embed_templates "hangman_html/*"
end
