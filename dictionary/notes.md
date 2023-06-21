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
