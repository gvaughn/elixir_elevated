defmodule Elevator.HallSignal do
  use GenServer

  @initial_state [] #of Elevator.Hail

  # TODO get rid of the default opts
  def start_link(opts \\ [name: :hall_signal]) do
    GenServer.start_link(__MODULE__, @initial_state, opts)
  end

  def floor_call(floor, dir, caller) do
    name = Application.get_env(:elevator, :hall_name)
    GenServer.cast(name, {:floor_call, %Elevator.Hail{floor: floor, dir: dir, caller: caller}})
  end

  # OTP handlers
  def handle_call({:retrieve, pos}, _from, state) do
    {:reply, Elevator.Hail.best_match(state, pos), state}
  end

  def handle_cast({:floor_call, call}, state) do
    gen_event_name = Application.get_env(:elevator, :event_name)
    GenEvent.notify(gen_event_name, {:hall_signal, :floor_call, call.floor})
    {:noreply, [call | state]}
  end

  def handle_cast({:arrival, pos}, state) do
    #TODO should multicast to all Cars to remove pos from their list
    #     GenServer.multi_call sends to same named proces on multiple nodes, so no help here
    # collect pids from :retrieve calls and iterate here (with a Task?)
    {:noreply, Elevator.Hail.reject_matching(state, pos)}
  end

end
