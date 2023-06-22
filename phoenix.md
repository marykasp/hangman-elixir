## Phoenix

### Install Phoenix
`mix` command has the ability to install local extensions. Each extension in an Elixir project that has been bundled into an archive,
the task that does this is `archive.install`.

`mix archive.install hex phx_new`

## Paths and Routes
- Phoenix has helpers that generate things such as HTML form elements, links, or buttons `core_components`
- Phoenix router decides which controller and action to use based on both the incoming URL path and the incoming HTTP request verb (`get`, `post`, `update`)
- `conn` value contains all the information that Phoenix is given about a particular request
  - when a request arrives it is initialized with the basic HTTP request info
  - as it continues to process the request, more info is added to `conn`
- `session` map is part of the `conn` value - Phoenix uses cookies to ensure that any values stored in the session in one request are made available in the session
on any subsequent requests from the same browser
- can use variaables in templates, these are called `assigns`. Inside the template prefix the aname with `@`
- these variables are passed in as the template is rendered `render(conn, action, key, value)`
- `render` lets you set the values of assigns in the template by passing a keyword list as the third parameter

```elixir
render(conn, :new, tally: tally)
```
- The Router generates helper functions which will generate correct URL (before update of verified routes)

To prevent posting from a form to occur each time page is reloaded need to have another action `:show` which  fbwill
get the updated tally and then display on the same page as a new game.

Therefore the `:new` and `:update` action will no longer `render` but instead will `redirect` to the new show page url, passing in the updated `game` struct on the `conn`
- `:new` starts a new game
- `:update` will pass in the user guess and make a move thereby returning

```elixir
  def new(conn, _params) do
    game = Hangman.new_game()
    conn
    |> put_session(:game, game)
    |> redirect(to: ~p"/hangman/current")
  end

  def update(conn, params) do
    IO.inspect(params)
    guess = params["guess"]

    conn
    |> get_session(:game)
    |> Hangman.make_move(guess)

    redirect(conn, to: ~p"/hangman/current")
  end


```
