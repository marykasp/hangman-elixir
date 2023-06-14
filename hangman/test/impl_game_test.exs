defmodule HangmanImplGameTest do
  use ExUnit.Case
  alias Hangman.Impl.Game

  test "new game returns game structure" do
    game = Game.new_game()

    assert game.turns_left == 7
    assert game.game_state == :initializing
    assert length(game.letters) > 0
  end

  test "new game returns correct word" do
    game = Game.new_game("wombat")

    assert game.turns_left == 7
    assert game.game_state == :initializing
    assert game.letters == ["w", "o", "m", "b", "a", "t"]
  end

  test "state doesn't change if game is won or lost" do
    for state <- [:won, :lost] do
      game = Game.new_game("wombat")
      # set state of game to won
      game = Map.put(game, :game_state, state)
      # call make move which returns a tuple of game struct and tally map
      {new_game, _tally} = Game.make_move(game, "x")

      assert new_game == game
    end
  end

  test "a duplicate letter is guessed" do
    game = Game.new_game()
    {game, _tally} = Game.make_move(game, "x")
    assert game.game_state != :already_used

    {game, _tally} = Game.make_move(game, "y")
    assert game.game_state != :already_used

    {game, _tally} = Game.make_move(game, "x")
    assert game.game_state == :already_used
  end

  test "we record new guess to MapSet" do
    game = Game.new_game()
    {game, _tally} = Game.make_move(game, "x")

    {game, _tally} = Game.make_move(game, "y")

    {game, _tally} = Game.make_move(game, "x")

    assert MapSet.equal?(game.used, MapSet.new(["x", "y"]))
  end

  test "recognize guess is in word and check state is updated good_guess" do
    game = Game.new_game("wombat")
    {_game, tally} = Game.make_move(game, "m")
    assert tally.game_state == :good_guess

    {_game, tally} = Game.make_move(game, "b")
    assert tally.game_state == :good_guess
  end

  test "recognize guess is not in word and check state is updated to bad_guess" do
    game = Game.new_game("wombat")
    {_game, tally} = Game.make_move(game, "n")
    assert tally.game_state == :bad_guess

    {_game, tally} = Game.make_move(game, "y")
    assert tally.game_state == :bad_guess
  end

  test "can handle a sequence of guesses" do
    # hello
    [
      # guess | state | turns_left | letters | used
      ["a", :bad_guess, 6, ["_", "_", "_", "_", "_"], ["a"]],
      ["a", :already_used, 6, ["_", "_", "_", "_", "_"], ["a"]],
      ["e", :good_guess, 6, ["_", "e", "_", "_", "_"], ["a", "e"]],
      ["x", :bad_guess, 5, ["_", "e", "_", "_", "_"], ["a", "e", "x"]]
    ]
    |> test_sequence_of_moves()
  end

  test "can handle a winning game" do
    # hello
    [
      # guess | state | turns_left | letters | used
      ["a", :bad_guess, 6, ["_", "_", "_", "_", "_"], ["a"]],
      ["a", :already_used, 6, ["_", "_", "_", "_", "_"], ["a"]],
      ["e", :good_guess, 6, ["_", "e", "_", "_", "_"], ["a", "e"]],
      ["x", :bad_guess, 5, ["_", "e", "_", "_", "_"], ["a", "e", "x"]],
      ["l", :good_guess, 5, ["_", "e", "l", "l", "_"], ["a", "e", "l", "x"]],
      ["o", :good_guess, 5, ["_", "e", "l", "l", "o"], ["a", "e", "l", "o", "x"]],
      ["h", :won, 5, ["h", "e", "l", "l", "o"], ["a", "e", "h", "l", "o", "x"]]
    ]
    |> test_sequence_of_moves()
  end

  test "can handle a losing game" do
    # hello
    [
      # guess | state | turns_left | letters | used
      ["a", :bad_guess, 6, ["_", "_", "_", "_", "_"], ["a"]],
      ["a", :already_used, 6, ["_", "_", "_", "_", "_"], ["a"]],
      ["c", :bad_guess, 5, ["_", "_", "_", "_", "_"], ["a", "c"]],
      ["x", :bad_guess, 4, ["_", "_", "_", "_", "_"], ["a", "c", "x"]],
      ["e", :good_guess, 4, ["_", "e", "_", "_", "_"], ["a", "c", "e", "x"]],
      ["g", :bad_guess, 3, ["_", "e", "_", "_", "_"], ["a", "c", "e", "g", "x"]],
      ["h", :good_guess, 3, ["h", "e", "_", "_", "_"], ["a", "c", "e", "g", "h", "x"]],
      ["i", :bad_guess, 2, ["h", "e", "_", "_", "_"], ["a", "c", "e", "g", "h", "i", "x"]],
      ["k", :bad_guess, 1, ["h", "e", "_", "_", "_"], ["a", "c", "e", "g", "h", "i", "k", "x"]],
      ["f", :lost, 0, ["h", "e", "_", "_", "_"], ["a", "c", "e", "f", "g", "h", "i", "k", "x"]]
    ]
    |> test_sequence_of_moves()
  end

  def test_sequence_of_moves(script) do
    game = Game.new_game("hello")
    Enum.reduce(script, game, &check_one_move/2)
  end

  def check_one_move([guess, state, turns, letters, used], game) do
    {game, tally} = Game.make_move(game, guess)

    assert tally.game_state == state
    assert tally.turns_left == turns
    assert tally.letters == letters
    assert tally.used == used
    game
  end
end
