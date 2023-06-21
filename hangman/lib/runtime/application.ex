defmodule Hangman.Runtime.Application do
  @moduledoc """
  Kicks off Hangman application.
  """
  @super_name GameStarter
  use Application

  # starts application running by generating a Supervisor that will supervise the Dynamic Supervisor
  def start(_type, _args) do
    supervisor_spec = [
      {DynamicSupervisor, strategy: :one_for_one, name: @super_name}
    ]

    Supervisor.start_link(supervisor_spec, strategy: :one_for_one)
  end

  # starts individual hangman server
  def start_game do
    DynamicSupervisor.start_child(@super_name, {Hangman.Runtime.Server, nil})
  end
end
