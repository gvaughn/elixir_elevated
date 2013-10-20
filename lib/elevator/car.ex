defmodule Elevator.Car do
  use GenServer.Behaviour

  @timeout 1000

  def start_link(num) do
    IO.puts "Elevator.Car starting num: #{num}"
    state = [num: num]
    :gen_server.start_link(__MODULE__, state, [])
  end

  #we should lookup HallMonitor by name each time we use it
  # in case it restarted in the meantime

  def init(state) do
    {:ok, state, @timeout}
  end

  def handle_info(:timeout, state) do
    num = Dict.get(state, :num)
    IO.puts "timeout called for: #{num}"
    {:noreply, state, @timeout}
    #TODO we might want the timeout for cast and calls so that it mimics the doors waiting
    # to close after floor selection
  end

end
