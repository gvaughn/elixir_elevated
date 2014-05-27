defmodule Elevator.Car do
  use GenServer

  @timeout 1000
  @initial_state [floor: 1, heading: 0, calls: [], num: 0] #TODO change state to a record?
  # heading(-1, 0, 1)

  def start_link(num) do
    GenServer.start_link(__MODULE__, num, [])
  end

  def init(num) do
    {:ok, Dict.put(@initial_state, :num, num), @timeout}
  end

  def go_to(pid, floor, caller) do
    GenServer.cast(pid, {:go_to, floor, caller})
  end

  # OTP handlers
  def handle_cast({:go_to, dest, caller}, state) do
    IO.puts "let's go to #{dest}"
    state = add_call(state, dest, caller)

    {:noreply, state, @timeout}
  end

  def handle_info(:timeout, state) do
    state = case state[:heading] do
      #TODO "arrival" is a bad name for an idle car
      0 -> arrival(state[:calls], state)
      _ -> travel(state)
    end
    {:noreply, state, @timeout}
  end

  defp arrival(calls, state) when length(calls) == 0 do
    case GenServer.call(:hall_signal, {:retrieve, state[:floor], state[:heading]}) do
      :none  -> state #nowhere to go
      dest   -> dispatch(dest, state)
    end
  end

  defp arrival(calls, state) do
    {curr_calls, other_calls} = Enum.split_while(state[:calls], &(&1.floor == state[:floor]))
    arrival_notice(curr_calls, state)
    GenServer.call(:hall_signal, {:arrival, state[:floor], state[:heading]})
    #TODO find a next_destination from calls if possible
    Dict.merge(state, [calls: other_calls])
  end

  defp travel(state) do
    new_floor = state[:floor] + state[:heading]
    new_heading = if should_stop?(new_floor, state) do
      #TODO too simple, we need to keep moving if we have more calls in that heading
      #TODO setting heading to 0 should be very rare -- when we have no pending calls and HallSignal
      #     can't give us one either
      0
    else
      IO.puts "passing #{new_floor}"
      state[:heading]
    end
    Dict.merge(state, [floor: new_floor, heading: new_heading])
  end

  defp should_stop?(floor, state) do
    hd(state[:calls]).floor == floor
    # TODO also should message HallMonitor to see if we can catch a rider in passing
  end

  defp dispatch(call, state) do
    Dict.merge(state, [heading: update_heading(call.floor - state[:floor]), calls: update_dest(state[:calls], call, state[:heading])])
  end

  defp update_heading(delta) do
    cond do
      delta == 0 -> 0
      delta > 0  -> 1
      true       -> -1
    end
  end

  defp update_dest(dests, item, heading) do
    #sorts by heading 1st and floor 2nd because of order of field of Elevator.Call
    #TODO but needs to be reversed order of floor?
    new_list = [item | dests] |> Enum.sort
    if heading > 0, do: new_list |> Enum.reverse,
    else: new_list
  end

  defp arrival_notice(arrivals, state) do
    Enum.each(arrivals, &(send(&1.caller, {:arrival, state[:floor], self})))
  end

  defp add_call(state, new_dest, caller) do
    new_call = Elevator.Call.create(state[:floor], new_dest, caller)
    #TODO can't always change heading to match new call
    Dict.merge(state, [heading: new_call.dir, calls: [new_call | state[:calls]]])
  end
end
