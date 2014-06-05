defmodule Elevator.HailTest do
  use ExUnit.Case
  alias Elevator.Hail

  test "best_match when closest is in opposite direction" do
    hails = [
      %Hail{floor: 5, dir: 1},
      %Hail{floor: 4, dir: -1}
    ]
    assert Hail.best_match(hails, %Hail{floor: 2, dir: 1}) == %Hail{floor: 5, dir: 1}
  end

  test "best_match when none in same direction" do
    hails = [
      %Hail{floor: 5, dir: -1},
      %Hail{floor: 1, dir: -1}
    ]
    assert Hail.best_match(hails, %Hail{floor: 4, dir: 1}) == %Hail{floor: 5, dir: -1}
  end

end

