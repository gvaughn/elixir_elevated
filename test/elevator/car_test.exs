defmodule Elevatar.CarTest do
  use ExUnit.Case, async: true
  alias Elevator.Car

  setup do
    {:ok, test_event} = GenEvent.start_link(name: :test_event)
    #TODO pass in the event manager to HallSignal.start_link to avoid printing during tests
    {:ok, car} = Elevator.Car.start_link({1, :test_event, :hall_signal, :infinity})
    {:ok, car: car}
  end

  test "hall hail 4 -> 2", %{car: car} do
    Elevator.floor_call(4, -1, self)
    assert_arrival(car, 4)
    Elevator.Car.go_to(car, 2, self)
    assert_arrival(car, 2)
  end

  test "2 hall hails 1 -> 3, 4 -> 2", %{car: car} do
    Elevator.floor_call(1, 1, self) #rider 1 hail
    tick(car)
    Elevator.floor_call(4, -1, self) # rider 2 hail
    assert_receive {:arrival, 1, ^car} # rider 1 boards
    Elevator.Car.go_to(car, 3, self) # rider 1 goes to 3
    assert_arrival(car, 3) # rider 1 exits
    assert_arrival(car, 4) # rider 2 boards
    Elevator.Car.go_to(car, 2, self) # rider 2 goes to 2
    assert_arrival(car, 2) # rider 2 exits
  end

  defp assert_arrival(car, floor) do
    continue(car)
    assert_receive {:arrival, floor, ^car}
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
