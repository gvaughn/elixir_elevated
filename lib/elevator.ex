defmodule Elevator do
  use Application

  def start(_type, [num_cars]) do
    Elevator.Supervisor.start_link(num_cars)
  end

  def call(floor, direction, rider_pid \\ self) do
    #TODO store the call into HallMonitor
    # Car polls HallMonitor and arrives
    # send message back to rider_pid with car_pid (or a CarInterface record?)
    # rider then tells Car where to go
    # Car informs rider when it arrives
    Elevator.HallSignal.floor_call(floor, direction, rider_pid)
  end

  def travel(from_floor, to_floor, rider_pid \\ self) do
    delta = to_floor - from_floor
    dir = trunc(delta/delta)
    call(from_floor, dir, rider_pid)
    receive do
      {:arrival, ^from_floor, elevator_pid} ->
        IO.puts("elevator pick up at: #{from_floor}")
        Elevator.Car.go_to(elevator_pid, to_floor, rider_pid)
    end
    receive do
      {:arrival, ^to_floor, _} ->
        IO.puts("Thank you, elevator. Rider departs at #{to_floor}")
    end
  end
  #TODO long-term create a macro to generate the rider process from dsl-ish params
end
