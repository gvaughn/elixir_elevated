defmodule Elevator.HallSignal do
  use GenServer

  def start_link(venue, opts \\ []) do
    #Note default imple of init stores its arg as state
    initial_state = %{venue: venue, hails: []}
    GenServer.start_link(__MODULE__, initial_state, opts)
  end

  #TODO consider moving to the BankSupervisor
  def floor_call(floor, dir, caller, bank) do
    name = :"Elevator.HallSignal-#{bank}"
    GenServer.cast(name, {:floor_call, %Elevator.Hail{floor: floor, dir: dir, caller: caller}})
  end

  # OTP handlers
  def handle_call({:retrieve, pos}, _from, state) do
    {:reply, Elevator.Hail.best_match(state.hails, pos), state}
  end

  def handle_cast({:floor_call, call}, state) do
    GenEvent.notify(state.venue, {:hall_signal, :floor_call, call.floor})
    {:noreply, %{state | hails: [call | state.hails]}}
  end

  def handle_cast({:arrival, pos}, state) do
    #TODO should multicast to all Cars to remove pos from their list
    #     GenServer.multi_call sends to same named proces on multiple nodes, so no help here
    # collect pids from :retrieve calls and iterate here (with a Task?)
    # or maybe ask the CarSupervisor to do it
    {:noreply, %{state | hails: Elevator.Hail.reject_matching(state.hails, pos)}}
  end

end
