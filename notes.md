## Type Specifications
Type specifications **typespecs** are annotations that you add to source files.
They are kind of half way between comments and code: have no effect on runtime, but like code
they are syntax checked by the compiler, cause additional metadata to be emitted to the complier output.

Typespecs are used to document elixir functions.
The spec line mirrors the function definition. It includes the function name, the type of each parameter, and the type of the return value.
```elixir
@spec titlecase(String.t) :: String.t
def titlecase(title) do
  # ...
end
```

In this function the parameter and return value are Elixir strings type of `String.t`

## Hangman Typespecs
Working out types of functions will get yout hinking about what they do and how they do it. It will also help
make sure that the APIs are tight as possible: writing out types explicitly will help see when you're leaking
implementation details out to the client.

Elixir divides its typings into types and specs.

`@type` annotation lets you create a new type in terms of other types.
`@opaque` annotation lets you define type whose contents are not usuable outside of module (keep state internal)
`@spec` shows the signature of a named function - type of parameter and type of returned value.

## Structures
Elixir maps gives us a way of bundling values togehter, with each value accessible using its key. One feature that
makes maps powerful is that you can add keys to them as the program runs.

Sometimes you may want to predefine the list of keys, and have Elixir prevent that structure from being changed during
runtime.

A **structure** is always associated with a module, and the structure will always have the name of the module (`%Hangman.Impl.Game{}`).
Structures are meant to hold the data that is processed by that module's functions.

`defstruct` declares a new structure, naming the fields and optionally giving an initial value.
The `new_game` method in the `Impl.Game` module then creates a new struct override the value stored in the letters field - uses `Dictionary`
module to get a random word and then splits that word into inidividual characters.

### Idiomatic structs
The name of the struct is always the name of the module that contains its definition. `__MODULE__` which always contains the current module name.
```elixir
def new_game() do
  %__MODULE__{
    letters: Dictionary.random_word |> String.codepoints
  }
end
```
Now you can change the name of your module without having to also change how you reference in the code.

It is conventional for a module that defines a struct to export a type named `t` describing that struct. This means that the code using the module can
reference the values being passed to and from the module as `ModuleName.t`

```elixir
@type t :: %Hangman.Impl.Game{
  turns_left: integer,
  game_state: Hangman.state,
  letters: list(String.t),
  used: MapSet.t(String.t)
}

```
In the API module can then refer to the type of game returned from the `new_game` function as `Game.t`. Because this is a public API, and because we want to keep the internals
of our internal state private, we alias `Game.t` type to a new public type, just called game. Use the `@opaque` attribute to say that the internals of the type should remain private
from anyone who imports it.

## Dependencies
The Dictionary app is added as a dependency. The `path:` path tells mix that it can find this dependency in our local file system, in a directory parallel to the current applicaiton.
You can also tell mix that a dependency is in a git repository. Most common way is via the `hex` package manager. Hex is both an online repo of packages and libraies that can be used
to fetch and store code. `https://hex.pm`

To include a hex dependency in profect, specify the application name and the version you require.

- Separate API from implementation - put API at top level `lib/` directory and implementation below that `lib/impl`
- `defdelegate` is a good way to ensure separ fbation
- `alias` does more than save typing - also lets you decouple your code from actual module names
- maps are a good way of representing state, `defstruct` can be used to make the structure static, predefining the keys and the default values

# Tests
- tests are located in subdirectory `test/`
- If a test is specific to a module, it is conventional to name it `<<modulename>>_test.exs`.
 ```elixir
ddefmodule SomeTest do
   use ExUnit.Case

   test "description" do
    assert <<expression>>
   end
  end
````
- The most common way to test to check something is using `assert`. Evaluates its argument and reports an error if `nil` or `false`
- can use `__MODULE__` as a convenient way to reference the current module name


Normally only test the public APIs of modules and never test internals. In this case actually looking at the module's state, which should be opaque to outside world.

## Pattern Matching Game State
- pattern matching can replace conditional code in functions.
- patterns can match at many levels

```elixir
def make_move(%{game_state: :won} = game, _guess) do
  {game, tally(game)}
```
The function will be called only if the first paramter is a map that has the key `game_state` that has a corresponding value of `:won`. The overall map is bound to the parameter `game`

- A pattern can match multiple values at different levels
```elixir
def make_move({%{game_state: state} = game, _guess})
```

This will match any call where the first parameter is a map containing a key `game_state`. The corresponding value will be bound to t he parameter `state`
- A `when` cluase (**guard clause**) can further restrict when a particular variant of a function can be called. `when` is executed after the parameters are bound

#### Avoid Conditional Logic Inside Functions
`if, unless, case, cond`

If you add a conditional statement to a function, you double the number of execution paths through it. One `if` means two paths. Elixir's pattern matching supports a style
of coding functions that can be conditional free. Instead you choose a single purpose for each variant of a function then use pattern matching and guard clauses to ensure the correct
variant is called in the correct context.

If the game state is not won or lost then need to check the guess the user made. Use a helper function `accept_guess(game, guess, boolean)` - `MapSet.member?(game.used, guess)` checks
if guess in in the `game.used` value. If so returns `true`. Use pattern matching on `accept_guess` for already_used guess and a new guess. An already used guess will change the
game state to `:already_used` and a new guess will be added to `game.used` (`MapSet.put(game.used, guess)`)

## Loops and State
Most languages uses loops to perform tasks. These loops will read and write from variables in the surrounding context. A global variable is set before the loop started (JS `while` loops).
It is then updated every iteration and tested to see if the loop is done.

In a functional language this is not possible since cannot update variables (immutable data). Instead need to use **recursion**.
Make body of loop the body of a function, and then have that function call itself at the end to kick off another iteration.

Typically a loop works on some values either reading or writing them and need to loop to terminate too. The functions in elixir cannot rely on the surrounding state.
Instead we need to pass the state into the function, first when start running it, and then each time it calls itself recursively. This allows the function to pass itself
updated state, and use that both as data to process and to know when to terminate.


### Tail call optimization
> "To iterate is human, to recurse, divine"

**TCO** is a compile-time trick that looks at code in recursive functions. The compiler determines that the last thing that a functiond does before exiting is to call itself, then it
can replace that call with a simple jump back to the top of the function's code. The compile just has to set the values of the local variable that hold the function's parameters before jumping.

The recursive call does not have to be the last line of the function it just has to be the las thing executed during a particular path through the function.

```elixir
def countdown(n) do
  IO.puts n
  if n > 0 do
    countdown(n-1)
  else
    IO.puts "LIFTOFF!"
  end
end
```

## Text Client
- Fleshed out the main components by writing some empty functions and some comments
- `@type` used to describe the state being passed into the recursive `interact` function - `{game, tally}`
  - both items of the state tuple type were defined in the `Hangman` module
- Inside the loop first need to get the state of the game (`tally.game_state`) and use pattern
matching on feedback function to determine what to print to the console
- Exposed the `tally(game)` function in the Hangman.Game module to the Hangman API client - need both the game `new_game()` and the tally `tally(game)` in order to start a game on
text client

# Spawn Processes
`spawn` runs a function in a separate process - takes either an anonymous function or (module, name of function, list of arguments)

`MFA` - Module, Function, Arguments
- the module part is simply its name, the function is the function name as an atom, and the arguments are represented as a list. The number of functions
in the list must match the arity of the function being called.
- `Process.sleep` delays the execution of the spawned function but starts the process (each has a unique `pid`)

Elixir processes are cheap - you can create one in less than 10microseconds and each takes less than 3k of memory (including their initial heap and stack)


```elixir
spawn(Procs, :hello, ["world"])
```

## Sending and Receiving Messages
- `send` function sends a message to a process
- `send pid, argument`
- `receive` waits for a message to arrive, binds it to a variable, then executes the associated code
```elixir
def hello do
  receive do
    msg ->
      IO.puts "Hello #{inspect(msg)}"
  end
  hello()
end

pid = spawn Procs, :hello, []
send pid, "elixir"
```
- messages sent to nonexistent processes are thrown away
- use recursion to implement a receiver loop in the process, once a `pid` receives a message it will shut down this prevents that

#### Pattern Matching Messages
- maintain state in the process by passing it as a parameter in the recursive call. You can update this state when handling a message
- use pattern matching in the body of the `receive` call

```elixir
receive do
  pattern_1 ->
    code

  pattern_2 ->
    code_2

  pattern_n ->
    code_n
end
```
- The incoming message is matched against each pattern in turn. When one matches, the corresponding code is run, and the receive is complete.
- `receive` waits for a message to arrive, binds it to a variable (will match on the correct pattern), then executes the associated code
- messages sent to nonexistent processes are thrown away

- `spawn` creates an **isolated process** - it is independent of the process that created it. Don't receive any notification that it has quit or died
- `spawn_link` links the creating and created process - if one dies (created process) the other is also killed

### Agents: Abstraction Over State
- Agents are an abstraction that keep state in a separate process
- call `Agent.start_link` with a function to initialize the state
- `Agent.get(pid, func)` runs the function in the agent, passing it the state. The value returned by the function is the value returned by `get`
- `Agent.update(pid, func)` runs the function the the agent, passing it the state. The value returned by the function becomes the new state
- `Agent.get_and_update(pid, func)` runs the function with the run. The function should return a two element tuple containing the return value to be passed
to the caller and the updated state.
