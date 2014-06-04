defmodule Elevator.HallSignal do
  use GenServer

  @name :hall_signal
  @initial_state [] #of Elevator.Hail

  def start_link() do
    GenServer.start_link(__MODULE__, @initial_state, [name: @name])
  end

  def floor_call(floor, dir, caller) do
    GenServer.cast(@name, {:floor_call, %Elevator.Hail{floor: floor, dir: dir, caller: caller}})
  end

  # OTP handlers
  def handle_cast({:floor_call, call}, state) do
    {:noreply, [call | state]}
  end

  def handle_call({:retrieve, pos}, _from, state) do
    {:reply, Elevator.Hail.best_match(state, pos), state}
  end

  # TODO should be a cast
  def handle_call({:arrival, floor, dir}, _from, state) do
    #GenEvent.notify(:elevator_events, {@name, :arrival, "at #{floor} heading #{dir}"})
    {:reply, :ok, Enum.filter(state, &(&1.floor == floor && &1.dir == dir))}
  end

end
