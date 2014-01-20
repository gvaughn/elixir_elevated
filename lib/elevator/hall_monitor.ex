defmodule Elevator.HallMonitor do
  use GenServer.Behaviour

  @name :hall_monitor
  @initial_state [calls: []]

  def start_link() do
    IO.puts "HallMonitor starting"
    :gen_server.start_link({:local, @name}, __MODULE__, @initial_state, [])
  end

  def floor_call(floor, direction, caller) do
    message_me({:floor_call, Elevator.Call.new(floor: floor, direction: direction, caller: caller)})
  end

  defp message_me(tuple) do
    :gen_server.cast(Process.whereis(@name), tuple)
  end

  # OTP handlers
  def handle_cast({:floor_call, call}, state) do
    IO.puts "received the floor_call message to #{call.floor}"
    state = Dict.update!(state, :calls, &[call | &1])
    {:noreply, state}
  end

  # called by Elevator.Car at rest looking for a destination floor
  # called by Elevator.Car when arrived at a destination floor
  def handle_call({:destination, vector}, _from, state) do
    #TODO use vector to pick best call to reply with
    calls = state[:calls]
    retval = cond do
      length(calls) == 0 -> {:none}
      true -> {:ok, hd(calls)}
    end
    {:reply, retval, state}
  end
end
