defmodule Elevator.Status do
  use GenEvent

  def start_link(display, opts \\ []) do
    case GenEvent.start_link(opts) do
      {:ok, pid} ->
        add_default_handler(display, pid)
        {:ok, pid}
      {:error, {:already_started, _pid}} ->
        :ignore
    end
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

