defmodule Elevator.Car do
  #use OtpDsl.Genserver
  use GenServer.Behaviour

  def start_link() do
    :gen_server.start_link({:local, :car1}, __MODULE__, [], [])
  end

  def init(state) do
    # this 3rd value is a timeout in millis before a handle_info(:timeout, state) callback is called
    {:ok, state, 1000}
  end

  def hi(), do: IO.inspect 'hello'

end
