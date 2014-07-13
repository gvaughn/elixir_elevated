defmodule Elevatar.CarTest do
  use ExUnit.Case
  alias Elevator.Car

  test "hall hail 4 -> 2" do
    Elevator.HallSignal.floor_call(4, -1, self)
    :timer.sleep(4000)
    assert_receive {:arrival, 4, _}
    Car.go_to(:car, 2, self)
    :timer.sleep(4000)
    assert_receive {:arrival, 2, _}
  end
end
