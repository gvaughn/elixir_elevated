defmodule Elevator.HallSignal do
  use GenServer

  def start_link(venue, bank, opts \\ []) do
    initial_state = %{bank: bank, venue: venue, hails: []}
    GenServer.start_link(__MODULE__, initial_state, opts)
  end

  def floor_call(bank, floor, dir, caller) do
    name = Elevator.BankSupervisor.hall_signal(bank)
    GenServer.cast(name, {:floor_call, %Elevator.Hail{floor: floor, dir: dir, caller: caller}})
  end

  def handle_call({:retrieve, pos}, _from, state) do
    {:reply, Elevator.Hail.best_match(state.hails, pos), state}
  end

  def handle_cast({:floor_call, call}, state) do
    GenEvent.notify(state.venue, {:hall_signal, :floor_call, call.floor})
    {:noreply, %{state | hails: [call | state.hails]}}
  end

  def handle_cast({:arrival, pos}, state) do
    Elevator.CarSupervisor.cast_all(state.bank, {:remove_hail, pos})
    {:noreply, %{state | hails: Elevator.Hail.reject_matching(state.hails, pos)}}
  end
end
