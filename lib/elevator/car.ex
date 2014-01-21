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
      0 -> arrival(state)
      _ -> travel(state)
    end
    {:noreply, state, @timeout}
    #TODO we might want the timeout for cast and calls so that it mimics the doors waiting
    # to close after floor selection
  end

  defp arrival(state) do
    #TODO check calls; if matches, inform riders to disembark, and remove from state[:calls]
    # inform HallMonitor we have arrived, so it can inform new riders which Car pid to communicate with
    # Then look to dispatch to our next_destination or else ask HallMonitor for one
    case message_hall_monitor(:destination, [state[:floor], state[:dir]]) do
      {:ok, dest} -> dispatch(dest, state)
      {:none}     -> state #nowhere to go
    end
  end

  defp travel(state) do
    state = Dict.update!(state, :floor, &(&1 + state[:dir]))
    arrived(state)
  end

  defp arrived(state) do
    #TODO this needs to go into arrival
    if should_stop?(state) do
      IO.puts "stopping at #{state[:floor]}"
      Dict.merge(state, [dir: 0, calls: List.delete(state[:calls], state[:floor])])
    else
      IO.puts "passing #{state[:floor]}"
      state
    end
  end

  defp should_stop?(state) do
    hd(state[:calls]) == state[:floor]
    # TODO also should message HallMonitor to see if we can catch a rider in passing
  end

  defp dispatch(call, state) do
    floor = call.floor
    #TODO needs to store calls
    Dict.merge(state, [dir: update_dir(floor - state[:floor]), calls: update_dest(state[:calls], floor, state[:dir])])
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
