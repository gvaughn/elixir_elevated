defmodule Elevator.Car do
  use GenServer.Behaviour

  def init(state) do
    # this 3rd value is a timeout in millis before a handle_info(:timeout, state) callback is called
    {:ok, state, 1000}
  end

  # trying to get the supervisor to start this. I didn't think I needed a specific start_link
  def start_link() do
    :gen_server.start_link({:local, :car1}, __MODULE__, [], [])
  end
end
