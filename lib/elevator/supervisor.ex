defmodule Elevator.Supervisor do
  use Supervisor.Behaviour

  def start_link(num_cars) do
    # num_cars comes from Elevator.start Application
    # see Programming Elixir 17.1 subsection: Managing Process State Across Restarts
    result = {:ok, sup} = :supervisor.start_link(__MODULE__, [])
    # 2nd param of start_link passed to init by supervisor
    start_workers(sup, num_cars)
    result
  end

  def init(_) do
    # init is expected to return child_specs
    # since we need to provide HallMonitor pid to the Cars, defer
    supervise([], strategy: :one_for_one)
  end

  def start_workers(sup, num_cars) do
    # start the HallMonitor here
    # {:ok, hm} = :supervisor.start_child
    Enum.map(1..num_cars, &(
      :supervisor.start_child(sup, worker(Elevator.Car, [&1], [id: "Elevator.Car-#{&1}"]))
    ))
  end
end
