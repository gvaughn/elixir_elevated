defmodule Elevator do
  use Application.Behaviour

  # See http://elixir-lang.org/docs/stable/Application.Behaviour.html
  # for more information on OTP Applications
  #def start(_type, _args) do
  def start(_type, [num_cars]) do
    Elevator.Supervisor.start_link(num_cars)
  end
end
