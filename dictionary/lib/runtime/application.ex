defmodule Dictionary.Runtime.Application do
  @moduledoc """
  Kicks off application.
  """
  use Application

  def start(_type, _args) do
    children = [{Dictionary.Runtime.Server, []}]

    # supervision strategy :one_for_one - if a child process terminates, only that process is restarted
    options = [
      name: Dictionary.Runtime.Supervisor,
      strategy: :one_for_one
    ]

    # starts agent - supervisor starts Dictionary server
    Supervisor.start_link(children, options)
  end
end
