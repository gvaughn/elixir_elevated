defmodule Elevatar.CarTest do
  use ExUnit.Case #,async: true
  alias Elevator.Car

  setup do
    {:ok, test_event} = GenEvent.start_link(name: :test_event)
    #TODO pass in the name to HallSignal.start_link
    {:ok, car} = Elevator.Car.start_link({1, :test_event, :hall_signal, :infinity})
    #on_exit(fn -> Elevator.Car.stop(car) end) #TODO teardown properly
    {:ok, car: car}
  end

  test "2 ticks arrives at floor 2", %{car: car} do
    Car.go_to(car, 2, self)
    tick(car)
    tick(car)
    assert_receive {:arrival, 2, ^car}
  end

  defp tick(car) do
    send(car, :timeout)
  end
end
