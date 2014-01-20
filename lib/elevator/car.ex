defmodule Elevator.Car do
  use GenServer.Behaviour

  @timeout 1000
  @initial_state [curr: 0, dir: 0, destinations: HashSet.new, num: 0]
  # dir(-1, 0, 1)
  # I'd like a sorted set for destinations

  def start_link(num) do
    IO.puts "Elevator.Car starting num: #{num}"
    state = Dict.put(@initial_state, :num, num)
    :gen_server.start_link(__MODULE__, state, [])
  end

  def init(state) do
    {:ok, state, @timeout}
  end

  def handle_info(:timeout, state) do
    state = case state[:dir] do
      0 -> destination(state)
      _ -> travel(state)
    end
    {:noreply, state, @timeout}
    #TODO we might want the timeout for cast and calls so that it mimics the doors waiting
    # to close after floor selection
  end

  defp destination(state) do
    case message_hall_monitor(:destination, [state[:curr], state[:dir]]) do
      {:ok, dest} -> dispatch(dest, state)
      {:none} ->     dispatch(next_destination(state), state)
    end
  end

  defp travel(state) do
    state = Dict.update!(state, :curr, &(&1 + state[:dir]))
    arrived(state)
  end

  defp arrived(state) do
    if should_stop?(state) do
      IO.puts "stopping at #{state[:curr]}"
      Dict.merge(state, [dir: 0, destinations: Set.delete(state[:destinations], state[:curr])])
    else
      IO.puts "passing #{state[:curr]}"
      state
    end
  end

  defp should_stop?(state) do
    Set.member?(state[:destinations], state[:curr])
    # TODO also should message HallMonitor to see if we can catch a rider in passing
  end

  defp next_destination(state) do
    IO.puts "figure out next destination"
    Elevator.Call.new(floor: state[:curr], direction: 0)
  end

  defp dispatch(call, state) do
    floor = call.floor
    # yuck, can we get a sorted set for the state.destinations?
    #TODO combine two updates into one merge
    state = Dict.update!(state, :destinations, &(Set.put(&1, floor) |> Set.to_list |> Enum.sort |> HashSet.new))
    Dict.update!(state, :dir, &update_vector(floor, state[:curr], &1))
  end

  defp update_vector(destination_floor, current_floor, direction) do
    if destination_floor == current_floor do
      0
    else
      abs(destination_floor - current_floor) / (destination_floor - current_floor) |> trunc
    end
  end

  defp message_hall_monitor(message, params) do
    :gen_server.call(Process.whereis(:hall_monitor), {message, params})
  end
end
