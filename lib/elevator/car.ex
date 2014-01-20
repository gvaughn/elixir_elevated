defmodule Elevator.Car do
  use GenServer.Behaviour

  @timeout 1000
  @initial_state [vector: {0, 0}, destinations: HashSet.new, num: 0]
  # vector {current_floor, direction (-1, 0, 1)}
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
    state = case state[:vector] do
      {_, 0} -> destination(state)
      _      -> travel(state)
    end
    {:noreply, state, @timeout}
    #TODO we might want the timeout for cast and calls so that it mimics the doors waiting
    # to close after floor selection
  end

  defp destination(state) do
    case message_hall_monitor(:destination, state[:vector]) do
      {:ok, dest} -> dispatch(dest.floor, state)
      {:none} -> state #nowhere to go
    end
  end

  defp travel(state) do
    state = Dict.update!(state, :vector, fn{curr, dir} -> {curr + dir, dir} end)
    arrived(state)
  end

  defp arrived(state) do
    {current_floor, _} = state[:vector]
    if should_stop?(state) do
      IO.puts "stopping at #{current_floor}"
      Dict.merge(state, [vector: {current_floor, 0}, destinations: Set.delete(state[:destinations], current_floor)])
    else
      IO.puts "passing #{current_floor}"
      state
    end
  end

  defp should_stop?(state) do
    {current_floor, _} = state[:vector]
    Set.member?(state[:destinations], current_floor)
    # TODO also should message HallMonitor to see if we can catch a rider in passing
  end

  defp dispatch(floor, state) do
    # yuck, can we get a sorted set for the state.destinations?
    state = Dict.update!(state, :destinations, &(Set.put(&1, floor) |> Set.to_list |> Enum.sort |> HashSet.new))
    Dict.update!(state, :vector, &update_vector(floor, &1))
  end

  defp update_vector(destination_floor, {current_floor, direction}) do
    if destination_floor == current_floor do
      {current_floor, 0}
    else
      {current_floor, abs(destination_floor - current_floor) / (destination_floor - current_floor) |> trunc}
    end
  end

  defp message_hall_monitor(message, params) do
    :gen_server.call(Process.whereis(:hall_monitor), {message, params})
  end
end
