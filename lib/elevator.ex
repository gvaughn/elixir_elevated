defmodule Elevator do
  use Application

  def start(_type, [num_cars]) do
    Elevator.Supervisor.start_link(num_cars)
  end

  def floor_call(from_floor, dir, rider_pid) do
    Elevator.HallSignal.floor_call(from_floor, dir, rider_pid)
  end

  def travel(from_floor, to_floor) do
    delta = to_floor - from_floor
    dir = trunc(delta/delta)
    floor_call(from_floor, dir, spawn(rider_fn(from_floor, to_floor)))
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
