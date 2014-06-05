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

  def handle_cast({:arrival, pos}, state) do
    {:noreply, Elevator.Hail.filter_by_hail(state, pos)}
  end

end
