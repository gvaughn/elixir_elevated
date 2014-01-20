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
      {_, 0} -> request_destination(state)
      _      -> travel(state)
    end
    {:noreply, state, @timeout}
    #TODO we might want the timeout for cast and calls so that it mimics the doors waiting
    # to close after floor selection
  end

  defp request_destination(state) do
    case message_hall_monitor(:destination, state[:vector]) do
      {:ok, dest} -> dispatch(dest.floor, state)
      {:none} -> state #nowhere to go
    end
  end

  defp travel(state) do
    IO.puts "here's where I move"
    state
  end

  defp dispatch(floor, state) do
    IO.puts "going to #{floor}"
    # yuck, can we get a sorted set for the state.destinations?
    state = Dict.update!(state, :destinations, &(Set.put(&1, floor) |> Set.to_list |> Enum.sort |> HashSet.new))
    Dict.update!(state, :vector, &update_vector(floor, &1))
  end

  defp update_vector(destination_floor, {current_floor, direction}) do
    abs(destination_floor - current_floor) / (destination_floor - current_floor) |> trunc
  end

  defp message_hall_monitor(message, params) do
    :gen_server.call(Process.whereis(:hall_monitor), {message, params})
  end
end
