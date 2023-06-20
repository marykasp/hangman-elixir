## Dictionary Application

Dictionary is an agent - stores state on a process
 - game implementation logic
 - runtime application

 1. start application with `mix run` - reads through `mix` file and looks at config settings
   - returns info about project (version number and elixir version to run with)
   - what to actually run? - invokes application callback - list of processes that need starting
    - which module starts the application `Dictionary.Runtime.Application`
    - reads in runtime application which has a start function - return the top level process
    - this top level process is the `Supervisor` - list of child processes that has to manage which references
    Runtime.Application, options with strategy of having processes being independent, kick of `Supervisor.start_link(children, options)`
    - supervisor process will start the children process specified
    - supervisor starts the child processes by loading the module - calls `child_spec` function and eventually calls `start_link` in module
      - calls `Agent.start_link` starts an agent process - this process is now linked to Supervisor - initialize it using the code in `WordList`
      - now in implementation side (`WordList`) - function is running in agent process which returns a word list

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
