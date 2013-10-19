defmodule Elevator.Car do
  #use OtpDsl.Genserver
  use GenServer.Behaviour

  @timeout 1000

  def start_link() do
    :gen_server.start_link({:local, :car1}, __MODULE__, [], [])
    # can't just use :car1 once we have multiple instances of Elevator.Car
  end

  def init(state) do
    {:ok, state, @timeout}
  end

  def hi(), do: IO.inspect 'hello'

  def handle_info(:timeout, state) do
    IO.puts "timeout called with state: #{state}"
    {:noreply, state, @timeout}
    #TODO we might want the timeout for cast and calls so that it mimics the doors waiting
    # to close after floor selection
  end

end
