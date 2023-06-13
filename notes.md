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
`@spec` shows the signature of a named function - type of parameter and type of returned value.
