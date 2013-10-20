defmodule Elevator do
  use Application.Behaviour

  def start(_type, [num_cars]) do
    Elevator.Supervisor.start_link(num_cars)
  end
end
