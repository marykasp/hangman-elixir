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
The functions passed as arguments to the calls to `Agent` functions are invoked inside the agent (the server). The server is started and then the function is called.
- Agents are an abstraction that keep state in a separate process
  - an agent contains just state - all functions that work on the state are provided **externally** - in calls to `get, update, get_and_update`
  - important to wrap agents inside a module, and only expose them through that modules API

- call `Agent.start_link` with a function to initialize the state
- `Agent.get(pid, func)` runs the function in the agent, passing it the state. The value returned by the function is the value returned by `get`
- `Agent.update(pid, func)` runs the function the the agent, passing it the state. The value returned by the function becomes the new state
- `Agent.get_and_update(pid, func)` runs the function with the run. The function should return a two element tuple containing the return value to be passed
to the caller and the updated state.

```elixir
defmodule HitCount do

  def start() do
    Agent.start_link(fn -> 0 end)
  end

  def record_hit(agent) do
    Agent.update(agent, &(&1 + 1))
  end

  def get_count(agent) do
    Agent.get(agent, &(&1))
  end
end
```

# Runtime and Compile Time
*Runtime* - environment in which the code runs
- process structure
- configuration
- error handling
- scaling

*Compile time* - code that implements the business logic
- problem specific
- algorithms
- data structures
- stuff that is unit tested
## Update Dictionary module
- initialize an Agent to store the state of the generated word list (holds the state) so don't have to generate the word list every time
start a new game

Steps taken to implement runtime vs compile time for Dictionary:
1. create a `runtime/server.ex` module that contains state without changing the logic - the implementation code has no idea whether it is running as
a directly-called library or in a separate process.
2. API change -> add a function to start the agent running
 - need to change the `@opaque` type `t` from being a `WordList.t` to a `Server.t`, this will not affect any code that used the dictionary.
 API module that can decouple details of the implementation from the clients of the code.

 `Dictionary Module`
`lib/impl/word_list/ex` - Library, runs in caller's process, caller holds state
 - called in the Agent
`lib/runtime/server.ex` - Process, runs in own process, holds own state - persists
  1. Controlled by client - call `start_link` to get it running, client manages lifecyle of dictionary

  2. Independent Process - started automatically, manages its own lifecycle (**application**)
    - project/library that also has its own lifecyle (starts and manages itself)

Run `Dictionary` as an Application
- an application can have a module that acts as its entry point - `lib/appname/application.ex` or in `lib/runtime/application.ex`
-  module must have a function `start/2` - this function is invoked automatically at runtime if register the entry pont module in `mix.exs`
`mod: {Dictionary.Runtime.Application, []}` when elixir runs the project it will call `start/2` function inside this listed module

- the `start/2` function should return the tuple `{:ok, pid}` where `pid` is the process ID of the root of the application
- module attributes are like constants - one use is to identify values used throughout the module - `@me or @pid` to refer to the registered name of the agent process

## Runtime Processes
Runtime maintains a registry - can be used to asscoiate names and pids. Once registered, you can use the name anywhere you could have used pid.
- adding `{name: @me}` to `Agent.start_link` call we are asking the agent library to handle the registration for us
- form of the `name:` option registers a anme that is local to the node that runs the code
- good to name your processes since if you need to be able to use them after they crash and get restarted. Such restarted processes will have a different pid, but the same
name will be mapped to the new pid.

Dictionary is now an agent - share one word list amongst any number of clients

# Supervisors
- supervisor monitors one or more processes
- a supervisor is just another process, supervisors can also monitor other supervisors - **supervision trees**
 - has nothing to do with process tree
 - keep application up and running
 - processes do the work and are separate from the supervision tree
- supervisors sit outside the regular process structure

### Add Supervisor to Dictionary
- supervisors start other processes, it's likely that the root level process of a supervised application will be the top level supervisor
- specify a supervisor inside the `application.ex` file
- `Supervisor.start_link`, passing a list of children and a set of options

## Worker Specifications
The supervisor needs to know a lof of information about each of the processes it manages. The list of children passed to `Supervisor.start_link` is a set of tuples, each containing
the name of a module and any parameters to be passed when the processes start.

Each of the child modules then implements function called `child_spec` which returns a data structure containing the child parameters.

Can use ELixir behaviors to create a default version. Updating `Runtime.Server` with `use Agent` adds the `child_spec function to the module`

## Supervisor Options
The second parameter to `Supervisor.start_link` is a keyword list. This list can contain many options, here are some common ones:
- `strategy: one_for_one | one_for_all | rest_for_one | simple_one_for_one`
- `max_restarts: n max_seconds: s`

Tells the supervisor how to handle child creation and failures. We used `one_for_one`, where each child process has an independent life. If a child process dies,
it alone is restarted and not the rest in the children list.
If more than `n` restarts occur in a period of specified seconds, the supervisor shuts down all its supervised processes and then terminates itself.
- `max_restarts` defaults to 1 and `max_seconds` defaults to 5 - so dictionary supervisor will be done when more than one restart happens in a 5 second period
### Processes
- mix.exs -> Runtime  -> application.ex -> Supervisor -> server.ex -> Agent -> word_list.ex

### Client Process
client code <-> Dictionary API (dictionary.ex) <-> Server interface (runtime/server.ex) [returns a message to client code]


server interace <-> agent process (Dictionary API (impl/word_list.ex)) <- supervisor (monitors)

Not multiplexing state - each process is managing its own state (self contained)
each client talk to own hangman process - the process is the state fore the game

processes in elixir world are called servers
- dictionary is an agent - an agent is a kind of server

`GenServer` - Erlang OTP framework, abstration of a generic server, two sets of APIs
will wrap any server in the elixir world (abstraction)
1. **External API** - start, invoke, monitor, stop (calling process)
2. **Internal callbacks** - initialize, handle requests, handle events (server process - code is called using callbacks)

```elixir
{:ok, pid} = GenServer.start_link(GameServer, args)

defmodule GameServer do
  use GenServer

  # use the arguments to create state
  def init(args) do
    state = create_state(args)
    # returns tuple with atom and state - state can be passed to all future callbacks that get invoked
    {:ok, state}
  end

  def handle_call({:make_move, guess}, _from, state) do
    # make the move, and update the state
    {:reply, return_value, new_state}
  end
end

return_value = GameServer.call(pid, {:make_move, "a"})

```

## Review of Code Organization - API, Server, Implementation Logic
- keep actual implementation separate from the code that is the server (`dictionary/impl/word_list`, `hangman/impl/game`)
- server is invoked from the API and then delegates processing to implementation

API (`dictionary.ex`, `hangman.ex`) -> `runtime/server` -> `impl/game, impl/word_list`
(dictionary also has an application layer in runtime which sets up a supervisor to manage child processes - if one crashes will be restarted)
- the state is stored on the servers

`my_project.ex` defines the API (no implementation just `defdelegate` to the server)
The files in the `impl` subdirectory implement the application logic. They are simple, linear code
The files under `runtime` implement all the functionality that makes the code actually run.
  - `application.ex` file is the interface to the Elixir runtime, telling it when to start
  - `server.ex` file implements the `GenServer` layer on top of the code in `impl`

## GenServer Behavior
Tell Elixir that a module implements the GenServer behavior with `use GenServer` expression.
  - `use` expression calls a macro in the given module, macro generates code that is injected back into module.
  - `GenServer` the macro tells Elixir taht our module can be used as a server, and defines defaul implementations of most of the callback functions.
  - `start_link` function is called directly by code that want to kick off our server. It runs in the same process as the code. Calls `GenServer.start_link` which starts
  the new server process.
  - Once that process is running the GenServer framework calls the `init` function which is responsible for returning the initial state `{:ok, game}`

- `:observer.start` in `iex -S mix` is an easy way to look into your server (including the current state - determine the pid, click on process and view state)

## SOP - Separation Of Concerns
Split code into 3 modules - API, server, and implementation
The API always sits at the top level, and the implementation and server in separate subdirectories (`impl`, `runtime`). The server is solely responsible for handling the
GenServer callbacks and managing the state (layer on top of the implementation code). The implementation is just a standalone set of functions that know how to get some problem
solved, but know nothing about the client, and nothing about being a server.
