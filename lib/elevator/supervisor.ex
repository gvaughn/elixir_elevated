defmodule Elevator.Supervisor do
  use Supervisor

  def start_link(num_cars) do
    Supervisor.start_link(__MODULE__, [num_cars])
    # 2nd param of start_link passed to init by supervisor
  end

  def init([num_cars]) do
    #children = [
      # Define workers and child supervisors to be supervised
      # worker(Elevator.Car, [])
      #]
    # need to use a more complex version so module is not used as id or else no duplicates
    # TODO explain child specs
    cars = Enum.map(1..num_cars, &(worker(Elevator.Car, [&1], [id: "Elevator.Car-#{&1}"])))
    monitor = worker(Elevator.HallSignal, [])

    #TODO :one_for_rest as in the ORA book?
    supervise([monitor | cars], strategy: :one_for_one)
  end
end
