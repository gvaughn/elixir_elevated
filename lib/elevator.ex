defmodule Elevator do
  use Application

  def start(_type, [num_cars]) do
    Elevator.Supervisor.start_link(num_cars)
  end

  def travel(from_floor, to_floor, rider_pid \\ self) do
    delta = to_floor - from_floor
    dir = trunc(delta/delta)
    Elevator.HallSignal.floor_call(from_floor, dir, rider_pid)
    if rider_pid == self do
      receive do
        {:arrival, ^from_floor, elevator_pid} ->
          IO.puts("elevator pick up at: #{from_floor}")
          Elevator.Car.go_to(elevator_pid, to_floor, rider_pid)
      end
      receive do
        {:arrival, ^to_floor, _} ->
          IO.puts("Thank you, elevator. Rider departs at #{to_floor}")
      end
    end
  end
  #TODO long-term create a macro to generate the rider process from dsl-ish params
end
