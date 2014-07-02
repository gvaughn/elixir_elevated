defmodule Elevator.Status do
  use GenEvent

  def start_link(display, opts \\ []) do
    # pid = case GenEvent.start_link(opts) do
    #   {:ok, pid} -> pid
    #   {:error, {:already_started, pid}} -> IO.puts "using already started GenEvent"; pid
    # end
    # add_default_handler(display, pid)
    # {:ok, pid}
    # TODO test with multiple banks on a single node sharing a Status
    {:ok, pid} = GenEvent.start_link(opts)
    add_default_handler(display, pid)
    {:ok, pid}
  end

  def init(_arg) do
    {:ok, []}
  end

  def handle_event(event, state) do
    IO.inspect(event)
    {:ok, state}
  end

  defp add_default_handler(display, pid) do
    case display do
      :stdout -> GenEvent.add_handler(pid, __MODULE__, [])
      :null -> nil
      :visual -> GenEvent.add_handler(pid, Elevator.VisualStatus, [])
    end
    pid
  end
end

