defmodule Elevator do
  use Application

  @hall_signal :hall_signal
  @car_tick 1000

  def start(_type, _args) do
    Elevator.HallSignal.start_link(name: @hall_signal)
    Elevator.Car.start_link({@hall_signal, @car_tick})
  end

  def test, do: (for {from, to} <- [{1,3}, {4,2}], do: travel(from, to))

  def travel(from_floor, to_floor) do
    dir = Elevator.Hail.dir(from_floor, to_floor)
    Elevator.HallSignal.floor_call(@hall_signal, from_floor, dir, spawn(rider_fn(from_floor, to_floor)))
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
