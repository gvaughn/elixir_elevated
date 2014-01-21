"""
Model individual Rider or a GroupOfRiders
An indiviaual Rider means it may be a group who do a Hall Call, each one then needs to select a destination floor
If GroupOfRiders, then the group can set multiple destinations. Of course an individual could do that too.

If individual Rider, then that affects whether the HallMonitor should create a logical call with its own pid
or if it could pass the Elevator.Call directly and the Car can inform the Rider

OK. We need to inform the HallMonitor of each stop we make and in that case it can give us extra queued Riders.
So, I think the 'destination' call into HallMonitor should create a dummy Call object with a nil pid. Our 'arrival'
logic can check for nil pids
"""
#TODO: state[:calls] needs to be instances of Elevator.Calls
#      HallMonitor needs to give us a Call with a nil pid on the 'destination' call
#      'arrival' needs to inform the pids of the Calls and HallMonitor

defmodule Elevator.Car do
  use GenServer.Behaviour

  @timeout 1000
  @initial_state [floor: 0, dir: 0, calls: [], num: 0]
  # dir(-1, 0, 1)

  def start_link(num) do
    state = Dict.put(@initial_state, :num, num)
    :gen_server.start_link(__MODULE__, state, [])
  end

  def init(state) do
    {:ok, state, @timeout}
  end

  # This is our heartbeat function to either handle arrival at a floor or travel to the next
  def handle_info(:timeout, state) do
    state = case state[:dir] do
      0 -> arrival(state[:calls], state)
      _ -> travel(state)
    end
    {:noreply, state, @timeout}
    #TODO we might want the timeout for cast and calls so that it mimics the doors waiting
    # to close after floor selection
  end

  defp arrival(calls, state) when length(calls) == 0 do
    case message_hall_monitor(:destination, [state[:floor], state[:dir]]) do
      {:ok, dest} -> dispatch(dest, state)
      {:none}     -> state #nowhere to go
    end
  end

  defp arrival(calls, state) do
    #FYI: currently we reshow "arrival at n" because we re-get the call from HallMonitor

    IO.puts "arrival at #{state[:floor]}"
    {curr_calls, other_calls} = Enum.split_while(state[:calls], &(&1.floor == state[:floor]))
    #TODO inform curr_calls if pid not nil of arrival
    #TODO inform HallMonitor we are here
    #TODO find a next_destination from calls if possible
    Dict.merge(state, [calls: other_calls])
  end

  defp travel(state) do
    new_floor = state[:floor] + state[:dir]
    new_dir = if should_stop?(new_floor, state) do
      0
    else
      IO.puts "passing #{new_floor}"
      state[:dir]
    end
    Dict.merge(state, [floor: new_floor, dir: new_dir])
  end

  defp should_stop?(floor, state) do
    hd(state[:calls]).floor == floor
    # TODO also should message HallMonitor to see if we can catch a rider in passing
  end

  defp dispatch(call, state) do
    Dict.merge(state, [dir: update_dir(call.floor - state[:floor]), calls: update_dest(state[:calls], call, state[:dir])])
  end

  defp update_dir(delta) do
    cond do
      delta == 0 -> 0
      delta > 0  -> 1
      true       -> -1
    end
  end

  defp update_dest(dests, item, dir) do
    new_list = [item | dests] |> Enum.sort
    if dir < 0, do: new_list |> Enum.reverse,
    else: new_list
  end

  defp message_hall_monitor(message, params) do
    :gen_server.call(Process.whereis(:hall_monitor), {message, params})
  end
end
