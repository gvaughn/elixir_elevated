defmodule Elevator do
  use Application.Behaviour
  alias Elevator.HallMonitor

  def start(_type, [num_cars]) do
    Elevator.Supervisor.start_link(num_cars)
  end

  def call(floor, direction, rider_pid) do
    #TODO store the call into HallMonitor
    # Car polls HallMonitor and arrives
    # send message back to rider_pid with car_pid (or a CarInterface record?)
    # rider then tells Car where to go
    # Car informs rider when it arrives
    HallMonitor.floor_call(floor, direction, rider_pid)
  end

  #TODO long-term create a macro to generate the rider process from dsl-ish params
end
