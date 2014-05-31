defmodule Elevator.Car do
  alias Elevator.Car
  use GenServer

  defstruct floor: 1, heading: 0, calls: [], num: 0
  # heading(-1, 0, 1)
  @timeout 1000

  def start_link(num) do
    GenServer.start_link(__MODULE__, num, [])
  end

  def init(num) do
    #TODO timeout could be a steady timer
    #  mostly if we want HallSignal to push calls to us
    #  as is, we're going to wait timeout after a rider is on and says :go_to
    #  which is not horrible in this simulation
    {:ok, %Elevator.Car{num: num}, @timeout}
  end

  # used once rider is on the elevator
  def go_to(pid, floor, caller) do
    GenServer.cast(pid, {:go_to, floor, caller})
  end

  # OTP handlers
  def handle_cast({:go_to, dest, caller}, state) do
    log(state, :go_to, dest)
    new_calls = Elevator.Call.add_call(state.calls, state.floor, dest, caller)
    #TODO can't always change heading to match new call
    state = %{state | calls: new_calls, heading: List.first(new_calls).dir}
    # but if I cahnge to this, riders will not be notified
    #state = %{state | calls: new_calls}

    {:noreply, state, @timeout}
  end

  def handle_info(:timeout, state = %Car{heading: 0, calls: []}) do
    # request Call from HallSignal
    state = case GenServer.call(:hall_signal, {:retrieve, state.floor, state.heading}) do
      :none  -> state #nowhere to go
      call   -> %{state | heading: Elevator.Call.dir(state.floor, call.floor), calls: [call]}
    end
    {:noreply, state, @timeout}
  end

  def handle_info(:timeout, state = %Car{heading: 0}) do
    # we're stopped, but have somewhere to go, so go
    {curr_calls, other_calls} = Enum.split_while(state.calls, &(&1.floor == state.floor))
    arrival_notice(curr_calls, state)
    GenServer.call(:hall_signal, {:arrival, state.floor, state.heading})
    #TODO find a new heading
    {:noreply, %{state | calls: other_calls}, @timeout}
  end

  def handle_info(:timeout, state) do
    # continue traveling
    new_floor = state.floor + state.heading
    new_heading = if should_stop?(new_floor, state) do
      #TODO too simple, we need to keep moving if we have more calls in that heading
      #TODO setting heading to 0 should be very rare -- when we have no pending calls and HallSignal
      #     can't give us one either
      0
    else
      log(state, :passing, new_floor)
      state.heading
    end
    {:noreply, %{state | floor: new_floor, heading: new_heading}, @timeout}
  end

  defp should_stop?(floor, state) do
    hd(state.calls).floor == floor
    # TODO also should message HallMonitor to see if we can catch a rider in passing
  end

  defp arrival_notice(arrivals, state) do
    Enum.each(arrivals, &(send(&1.caller, {:arrival, state.floor, self})))
  end

  defp log(state, action, msg) do
    GenEvent.notify(:elevator_events, {:"elevator#{state.num}", action, msg})
  end
end
