defmodule Elevator.Supervisor do
  use Supervisor

  def start_link(num_cars) do
    Supervisor.start_link(__MODULE__, [num_cars])
  end

  def init([num_cars]) do
    #children = [
      # Define workers and child supervisors to be supervised
      # worker(Elevator.Car, [])
      #]
    # need to use a more complex child specs so module is not used as id or else no duplicates
    #TODO receive params for elevator_events, hall_signal, tick
    GenEvent.start_link(name: :elevator_events)
    #TODO add to mix.exs the registerd name
    stream = GenEvent.stream(:elevator_events)
    #TODO expand this idea into an ansi terminal visual display
    spawn_link fn ->
      for {who, what, msg} <- stream do
        IO.puts "#{who} says #{what} and #{msg}"
      end
    end
    cars = Enum.map(1..num_cars, &(worker(Elevator.Car, [{&1, :elevator_events, :hall_signal, 1000}], [id: "Elevator.Car-#{&1}"])))
    signal = worker(Elevator.HallSignal, [])

    supervise([signal | cars], strategy: :one_for_one)
  end
end
