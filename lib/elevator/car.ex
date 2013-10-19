defmodule Elevator.Car do
  #use OtpDsl.Genserver
  use GenServer.Behaviour

  @timeout 1000

  def start_link(num) do
    IO.puts "Elevator.Car starting num: #{num}"
    state = [num: num]
    :gen_server.start_link(__MODULE__, state, [])
    # could use start_link/4 if we want to register a process name
  end

  def init(state) do
    {:ok, state, @timeout}
  end

  def hi(), do: IO.inspect 'hello'

  def handle_info(:timeout, state) do
    num = Dict.get(state, :num)
    IO.puts "timeout called for: #{num}"
    {:noreply, state, @timeout}
    #TODO we might want the timeout for cast and calls so that it mimics the doors waiting
    # to close after floor selection
  end

end
