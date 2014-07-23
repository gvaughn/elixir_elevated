defmodule Elevator do
  use Application

  @hall_signal :hall_signal
  @car_tick 1000
  @venue :elevator_events

  def start(_type, _args) do
    GenEvent.start_link(name: @venue)
    if Mix.env != :test do
      spawn_link fn -> for e <- GenEvent.stream(@venue), do: IO.inspect e end
    end
    Elevator.HallSignal.start_link(@venue, name: @hall_signal)
    Elevator.Car.start_link({@venue, @hall_signal, @car_tick})
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
          GenEvent.notify(@venue, {"rider", :embark, from_floor})
          Elevator.Car.go_to(elevator_pid, to_floor, self)
      end
      receive do
        {:arrival, ^to_floor, _} ->
          GenEvent.notify(@venue, {"rider", :disembark, from_floor})
      end
    end
  end
end
