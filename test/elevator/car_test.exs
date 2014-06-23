defmodule Elevatar.CarTest do
  use ExUnit.Case, async: true
  alias Elevator.Car

  setup do
    # TODO Should I start a Bank instead?
    {:ok, _hall} = Elevator.HallSignal.start_link(:elevator_events, [name: :"Elevator.HallSignal-TEST"])
    {:ok, car} = Elevator.Car.start_link({1, :elevator_events, :"Elevator.HallSignal-TEST", :infinity})
    {:ok, car: car}
  end

  test "hall hail 4 -> 2", %{car: car} do
    Elevator.floor_call(4, -1, self, "TEST")
    assert_arrival(car, 4)
    Car.go_to(car, 2, self)
    assert_arrival(car, 2)
  end

  test "2 hall hails 1 -> 3, 4 -> 2", %{car: car} do
    Elevator.floor_call(1, 1, self, "TEST") #rider 1 hail
    tick(car)
    Elevator.floor_call(4, -1, self, "TEST") # rider 2 hail
    assert_receive {:arrival, 1, ^car} # rider 1 boards
    Car.go_to(car, 3, self) # rider 1 goes to 3
    assert_arrival(car, 3) # rider 1 exits
    assert_arrival(car, 4) # rider 2 boards
    Car.go_to(car, 2, self) # rider 2 goes to 2
    assert_arrival(car, 2) # rider 2 exits
  end

  defp assert_arrival(car, floor) do
    continue(car)
    assert_receive {:arrival, ^floor, ^car}
  end

  defp continue(car) do
    tick(car)
    case :erlang.process_info(self, :message_queue_len) do
      {:message_queue_len, 0} -> continue(car)
      {:message_queue_len, _} -> nil
    end
  end

  defp tick(car), do: send(car, :timeout)
end
