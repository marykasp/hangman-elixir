defmodule Dictionary.Runtime.Application do
  @moduledoc """
  Kicks off application.
  """
  use Application

  def start(_type, _args) do
    # starts agent
    Dictionary.Runtime.Server.start_link()
  end
end
