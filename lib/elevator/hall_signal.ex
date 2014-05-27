defmodule Elevator.Call do
  defstruct dir: 1, floor: 1, caller: nil

  #TODO add methods to keep list of Call's sorted here?
end

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
    {:noreply, Enum.uniq([call | state])}
  end

  def handle_call({:destination, _}, _from, state) when length(state) == 0 do
    {:reply, {:none}, state}
  end

  # called by Elevator.Car at rest looking for a destination floor
  def handle_call({:destination, [current_floor, dir]}, _from, state) do
    #TODO refactor me need to find better match that just first
    {:reply, {:ok, hd(state)}, state}
  end

  def handle_call({:arrival, [floor, dir]}, from, state) do
    IO.puts "Elevator arrival at #{floor} heading #{dir}"
    state = Enum.filter(state, &(&1.floor == floor && &1.dir == dir))
    {:reply, :ok, state}
  end

end
