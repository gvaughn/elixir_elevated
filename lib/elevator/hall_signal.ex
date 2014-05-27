defmodule Elevator.HallSignal do
  use GenServer

  @name :hall_signal
  @initial_state [] #of Elevator.Calls

  def start_link() do
    GenServer.start_link(__MODULE__, @initial_state, [name: @name])
  end

  def floor_call(floor, dir, caller) do
    GenServer.cast(@name, {:floor_call, %Elevator.Call{floor: floor, dir: dir, caller: caller}})
  end

  # OTP handlers
  def handle_cast({:floor_call, call}, state) do
    {:noreply, [call | state]}
  end

  # called by Elevator.Car at rest looking for a destination floor
  def handle_call({:retrieve, current_floor, dir}, _from, state) do
    {:reply, Elevator.Call.best_match(state, current_floor, dir), state}
  end

  def handle_call({:arrival, floor, dir}, _from, state) do
    IO.puts "Elevator arrival at #{floor} heading #{dir}"
    state = Enum.filter(state, &(&1.floor == floor && &1.dir == dir))
    {:reply, :ok, state}
  end

end
