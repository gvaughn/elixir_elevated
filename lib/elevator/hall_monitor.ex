defmodule Elevator.HallMonitor do
  use GenServer.Behaviour

  def start_link() do
    IO.puts "HallMonitor starting"
    state = []
    :gen_server.start_link({:local, :hall_monitor}, __MODULE__, state, [])
  end
end
