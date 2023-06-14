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
- `defdelegate` is a good way to ensure separation
- `alias` does more than save typing - also lets you decouple your code from actual module names
- maps are a good way of representing state, `defstruct` can be used to make the structure static, predefining the keys and the default values
-
