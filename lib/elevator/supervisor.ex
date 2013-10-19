defmodule Elevator.Supervisor do
  use Supervisor.Behaviour

  def start_link(num_cars) do
    # num_cars comes from Elevator.start Application
    # this may get more complex if I have to start a HallMonitor and pass its pid to the Cars
    # see iPad p#597 of Programming Elixir 17.1 subsection: Managing Process State Across Restarts
    :supervisor.start_link(__MODULE__, [num_cars])
    # 2nd param of start_link passed to init by supervisor
  end

  def init([num_cars]) do
    #children = [
      # Define workers and child supervisors to be supervised
      # worker(Elevator.Car, [])
      #]
    # need to use a more complex version so module is not used as id or else no duplicates
    children = Enum.map(1..num_cars, &(worker(Elevator.Car, [&1], [id: "Elevator.Car-#{&1}"])))
    #IO.inspect children

    # See http://elixir-lang.org/docs/stable/Supervisor.Behaviour.html
    # for other strategies and supported options
    supervise(children, strategy: :one_for_one)
  end
end
