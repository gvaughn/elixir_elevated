defmodule Elevator.Call do
  defstruct dir: 1, floor: 1, caller: nil
end

defmodule Elevator.HallSignal do
  use GenServer

  @name :hall_signal
  @initial_state [calls: []]

  def start_link() do
    IO.puts "HallSignal starting"
    GenServer.start_link(__MODULE__, @initial_state, [name: @name])
  end

  def floor_call(floor, dir, caller) do
    GenServer.cast(@name, {:floor_call, %Elevator.Call{floor: floor, dir: dir, caller: caller}})
  end

  # OTP handlers
  def handle_cast({:floor_call, call}, state) do
    IO.puts "received the floor_call message to #{call.floor}"
    #TODO can't be quite this simple
    # need to look for assigned call floors and put in one of two fields
    state = Dict.update!(state, :calls, &[call | &1])
    {:noreply, state}
  end

  # called by Elevator.Car at rest looking for a destination floor
  def handle_call({:destination, [current_floor, dir]}, _from, state) do
    #TODO use current_floor and dir to pick best call to reply with
    calls = state[:calls]
    retval = cond do
      length(calls) == 0 -> {:none}
      true               -> {:ok, destination_call(state)}
    end
    {:reply, retval, state}
  end

  def handle_call({:arrival, [floor, dir]}, from, state) do
    IO.puts "Elevator arrival at #{floor} heading #{dir}"
    {:reply, :ok, state}
  end

  defp destination_call(state) do
    #TODO refactor me
    # need to have extra state field for calls already assigned
    rider_call = hd(state[:calls])
    %Elevator.Call{floor: rider_call.floor, dir: rider_call.dir}
  end
end
