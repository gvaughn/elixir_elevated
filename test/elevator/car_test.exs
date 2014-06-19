defmodule Elevatar.CarTest do
  use ExUnit.Case, async: true
  alias Elevator.Car

  setup do
    {:ok, test_event} = GenEvent.start_link(name: :test_event)
    #TODO pass in the event manager to HallSignal.start_link to avoid printing during tests
    {:ok, car} = Elevator.Car.start_link({1, :test_event, :hall_signal, :infinity})
    {:ok, car: car}
  end

  test "hall hail at current floor", %{car: car} do
    Elevator.floor_call(1, 1, self)
    tick(car)
    assert_receive {:arrival, 1, ^car}
  end

  test "hall hail 4 -> 2", %{car: car} do
    Elevator.floor_call(4, -1, self)
    tick(car, 4)
    assert_receive {:arrival, 4, ^car}
    Elevator.Car.go_to(car, 2, self)
    tick(car, 3)
    assert_receive {:arrival, 2, ^car}
  end

  test "2 hall hails 1 -> 3, 4 -> 2", %{car: car} do
    Elevator.floor_call(1, 1, self)
    tick(car)
    Elevator.floor_call(4, -1, self)
    assert_receive {:arrival, 1, ^car} #first call
    Elevator.Car.go_to(car, 3, self) # rider select's 3
    tick(car, 3)
    assert_receive {:arrival, 3, ^car}
    tick(car, 2)
    assert_receive {:arrival, 4, ^car}
    Elevator.Car.go_to(car, 2, self) # rider 2 select's 2
    tick(car, 3)
    assert_receive {:arrival, 2, ^car}
  end

  defp tick(car, times \\ 1) do
    Enum.each(1..times, fn(_) -> send(car, :timeout) end)
  end
end
