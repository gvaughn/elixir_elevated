defmodule Elevator.Status do
  use GenEvent

  def start_link(display, opts \\ []) do
    pid = case GenEvent.start_link(opts) do
      {:ok, pid} -> pid
      {:error, {:already_started, pid}} -> pid
    end
    add_default_handler(display, pid)
    {:ok, pid}
  end

  def init(_arg) do
    # arg is the 3rd param to GenEvent.add_handler
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
      #TODO expand this idea into an ansi terminal visual display
    end
    pid
  end
end
