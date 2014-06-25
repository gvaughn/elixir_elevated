defmodule Elevator.HallSignal do
  use GenServer

  def start_link(venue, opts \\ []) do
    #Note default imple of init stores its arg as state
    initial_state = %{venue: venue, hails: [], cars: []}
    GenServer.start_link(__MODULE__, initial_state, opts)
  end

  def floor_call(bank, floor, dir, caller) do
    name = Elevator.BankSupervisor.hall_signal(bank)
    GenServer.cast(name, {:floor_call, %Elevator.Hail{floor: floor, dir: dir, caller: caller}})
  end

  # OTP handlers
  def handle_call({:retrieve, pos}, _from = {pid, _ref}, state) do
    new_state = %{state | cars: [pid | state.cars]}
    {:reply, Elevator.Hail.best_match(state.hails, pos), new_state}
  end

  def handle_cast({:floor_call, call}, state) do
    GenEvent.notify(state.venue, {:hall_signal, :floor_call, call.floor})
    {:noreply, %{state | hails: [call | state.hails]}}
  end

  def handle_cast({:arrival, pos}, state) do
    Task.async(fn -> remove_hail(state.cars, pos) end)
    {:noreply, %{state | hails: Elevator.Hail.reject_matching(state.hails, pos)}}
  end

  defp remove_hail(cars, hail) do
    Enum.each(cars, &(GenServer.cast(&1, {:remove_hail, hail})))
  end
end
