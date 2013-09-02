defmodule Elevator.Supervisor do
  use Supervisor.Behaviour

  def start_link do
    # this may get more complex if I have to start a HallMonitor and pass its pid to the Cars
    # see iPad p#597 of Programming Elixir 17.1 subsection: Managing Process State Across Restarts
    :supervisor.start_link(__MODULE__, [])
  end

  def init([]) do
    children = [
      # Define workers and child supervisors to be supervised
      # worker(Elevator.Worker, [])
      worker(Elevator.Car, [])
    ]

    # See http://elixir-lang.org/docs/stable/Supervisor.Behaviour.html
    # for other strategies and supported options
    supervise(children, strategy: :one_for_one)
  end
end
