defmodule Elevator do
  use Application

  def start(_type, _args) do
    Elevator.HallSignal.start_link
    Elevator.Car.start_link
  end

  def test, do: (for {from, to} <- [{1,3}, {4,2}], do: travel(from, to))

  def travel(from_floor, to_floor) do
    dir = Elevator.Hail.dir(from_floor, to_floor)
    Elevator.HallSignal.floor_call(from_floor, dir, spawn(rider_fn(from_floor, to_floor)))
  end

  defp rider_fn(from_floor, to_floor) do
    fn ->
      receive do
        {:arrival, ^from_floor, elevator_pid} ->
          IO.puts "rider embarks at #{from_floor}"
          Elevator.Car.go_to(elevator_pid, to_floor, self)
      end
      receive do
        {:arrival, ^to_floor, _} ->
          IO.puts "rider disembarks at #{to_floor}"
      end
    end
  end
end
