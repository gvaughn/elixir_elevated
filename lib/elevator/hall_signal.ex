defmodule Elevator.HallSignal do
  use GenServer

  def start_link(venue, opts \\ []) do
    GenServer.start_link(__MODULE__, %{hails: [], venue: venue}, opts)
  end

  def floor_call(name, floor, dir, caller) do
    GenServer.cast(name, {:floor_call, %Elevator.Hail{floor: floor, dir: dir, caller: caller}})
  end

  def handle_call({:retrieve, pos}, _from, state) do
    {:reply, Elevator.Hail.best_match(state.hails, pos), state}
  end

  def handle_cast({:floor_call, call}, state) do
    GenEvent.notify(state.venue, {"hall_signal", :floor_call, call.floor})
    {:noreply, %{state | hails: [call | state.hails]}}
  end

  def handle_cast({:arrival, pos}, state) do
    {:noreply, %{state | hails: Elevator.Hail.reject_matching(state.hails, pos)}}
  end
end
