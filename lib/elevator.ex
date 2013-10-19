defmodule Elevator do
  use Application.Behaviour

  # See http://elixir-lang.org/docs/stable/Application.Behaviour.html
  # for more information on OTP Applications
  def start(_type, _args) do
    Elevator.Supervisor.start_link(2)
    # TODO parametrize num_cars (2) into .app file
  end
end
