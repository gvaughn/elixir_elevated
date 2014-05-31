defmodule Elevator.Car do
  use GenServer

  defstruct floor: 1, heading: 0, calls: [], num: 0
  # heading(-1, 0, 1)
  @timeout 1000

  def start_link(num) do
    GenServer.start_link(__MODULE__, num, [])
  end

  def init(num) do
    {:ok, %Elevator.Car{num: num}, @timeout}
  end

  def go_to(pid, floor, caller) do
    GenServer.cast(pid, {:go_to, floor, caller})
  end

  # OTP handlers
  def handle_cast({:go_to, dest, caller}, state) do
    log(state, :go_to, dest)
    new_calls = Elevator.Call.add_call(state.calls, state.floor, dest, caller)
    #TODO can't always change heading to match new call and it may not always be first anyway
    state = %{state | heading: List.first(new_calls).dir, calls: new_calls}

    {:noreply, state, @timeout}
  end

  def handle_info(:timeout, state) do
    state = case state.heading do
      #TODO "arrival" is a bad name for an idle car
      0 -> arrival(state.calls, state)
      _ -> travel(state)
    end
    {:noreply, state, @timeout}
  end

  defp arrival(calls, state) when length(calls) == 0 do
    case GenServer.call(:hall_signal, {:retrieve, state.floor, state.heading}) do
      :none  -> state #nowhere to go
      dest   -> dispatch(dest, state)
    end
  end

  defp arrival(calls, state) do
    {curr_calls, other_calls} = Enum.split_while(state.calls, &(&1.floor == state.floor))
    arrival_notice(curr_calls, state)
    GenServer.call(:hall_signal, {:arrival, state.floor, state.heading})
    #TODO find a next_destination from calls if possible
    %{state | calls: other_calls}
  end

  defp travel(state) do
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
    %{state | floor: new_floor, heading: new_heading}
  end

  defp should_stop?(floor, state) do
    hd(state.calls).floor == floor
    # TODO also should message HallMonitor to see if we can catch a rider in passing
  end

  defp dispatch(call, state) do
    %{state | heading: Elevator.Call.dir(state.floor, call.floor), calls: update_dest(state.calls, call, state.heading)}
  end

  defp update_dest(dests, item, heading) do
    #sorts by heading 1st and floor 2nd because of order of field of Elevator.Call
    #TODO but needs to be reversed order of floor?
    new_list = [item | dests] |> Enum.sort
    if heading > 0, do: new_list |> Enum.reverse,
    else: new_list
  end

  defp arrival_notice(arrivals, state) do
    Enum.each(arrivals, &(send(&1.caller, {:arrival, state.floor, self})))
  end

  defp log(state, action, msg) do
    GenEvent.notify(:elevator_events, {:"elevator#{state.num}", action, msg})
  end
end
