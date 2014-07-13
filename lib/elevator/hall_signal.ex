defmodule Elevator.HallSignal do
  use GenServer

  def start_link do
    GenServer.start_link(__MODULE__, %{hails: []}, [name: :hall_signal])
  end

  def floor_call(floor, dir, caller) do
    GenServer.cast(:hall_signal, {:floor_call, %Elevator.Hail{floor: floor, dir: dir, caller: caller}})
  end

  def handle_call({:retrieve, pos}, _from, state) do
    {:reply, Elevator.Hail.best_match(state.hails, pos), state}
  end

  def handle_cast({:floor_call, call}, state) do
    IO.puts "hall_signal received a floor_call to #{call.floor}"
    {:noreply, %{state | hails: [call | state.hails]}}
  end

  def handle_cast({:arrival, pos}, state) do
    {:noreply, %{state | hails: Elevator.Hail.reject_matching(state.hails, pos)}}
  end
end
