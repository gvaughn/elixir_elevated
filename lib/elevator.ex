defmodule Elevator do
  use Application

  def start(_type, [num_cars]) do
    #TODO use anonymous Supervisor
    GenEvent.start_link(name: :elevator_events)
    #TODO add to mix.exs the registerd name
    stream = GenEvent.stream(:elevator_events)
    spawn_link fn ->
      for {who, what, msg} <- stream do
        IO.puts "#{who} says #{what} and #{msg}"
      end
    end
    Elevator.Supervisor.start_link(num_cars)
  end

  def floor_call(from_floor, dir, rider_pid) do
    Elevator.HallSignal.floor_call(from_floor, dir, rider_pid)
  end

  def travel(from_floor, to_floor) do
    floor_call(from_floor, Elevator.Hail.dir(from_floor, to_floor), spawn(rider_fn(from_floor, to_floor)))
  end

  defp rider_fn(from_floor, to_floor) do
    fn ->
      receive do
        {:arrival, ^from_floor, elevator_pid} ->
          IO.puts("elevator pick up at: #{from_floor}")
          Elevator.Car.go_to(elevator_pid, to_floor, self)
      end
      receive do
        {:arrival, ^to_floor, _} ->
          IO.puts("Thank you, elevator. Rider departs at #{to_floor}")
      end
    end
  end
end
