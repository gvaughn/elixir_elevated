defmodule Elevator.HallMonitor do
  use GenServer.Behaviour

  @name :hall_monitor
  @initial_state [calls: []]

  def start_link() do
    IO.puts "HallMonitor starting"
    :gen_server.start_link({:local, @name})
  end

  def floor_call(floor, direction, caller) do
    call = Elevator.Call.new(floor: floor, direction: direction, caller: caller)
    :gen_server.cast(Process.whereis(@name), {:floor_call, call})
  end

  # OTP handlers
  def handle_cast({:floor_call, call}, state) do
    IO.puts "received the floor_call message to #{call.floor}"
    state[:calls] = [call | state[:calls]]
    {:noreply, state}
  end
end
