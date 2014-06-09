module Elevatar.CarTest do
  use ExUnit.Case
  alias Elevator.Car

  #TODO setup/teardown like unpublished tutorial on elixir-lang.org
  test "blah" do
    Car.go_to(car, 2, self)
    assert_receive {:arrival, 2, ^car}
  end
end
