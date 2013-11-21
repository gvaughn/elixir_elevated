defmodule Elevator.Car do
  use GenServer.Behaviour

  @timeout 1000
  @initial_state [vector: {0, 0}, destinations: [], num: 0]
  # vector {current_floor, direction (-1, 0, 1)}

  def start_link(num) do
    IO.puts "Elevator.Car starting num: #{num}"
    state = Dict.put(@initial_state, :num, num)
    :gen_server.start_link(__MODULE__, state, [])
  end

  #we should lookup HallMonitor by name each time we use it
  # in case it restarted in the meantime

  def init(state) do
    {:ok, state, @timeout}
  end

  def handle_info(:timeout, state) do
    #IO.puts "timeout called for: #{Dict.get(state, :num)}"
    #TODO the line below causes crash
    state = travel(state[:vector], state)
    {:noreply, state, @timeout}
    #TODO we might want the timeout for cast and calls so that it mimics the doors waiting
    # to close after floor selection
  end

  defp travel({_,0}, state) do
    # can I pattern match the vector's direction from full state keyword list?
    case message_hall_monitor(:destination, state[:vector]) do
      {:ok, dest} -> IO.puts "go to #{dest.floor}"
      {:none} -> nil #IO.puts "nowhere to go"
    end
    state
  end

  defp message_hall_monitor(message, params) do
    :gen_server.call(Process.whereis(:hall_monitor), {message, params})
  end
end
