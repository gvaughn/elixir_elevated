defmodule Elevator.Status do
  use GenEvent

  def start_link(display, opts \\ []) do
    IO.puts "starting GenEvent with #{inspect opts}"
    # pid = :global.whereis_name(opts[:name])
    # if pid != :undefined do
    #   IO.puts "using already started GenEvent"
    #   add_default_handler(display, pid)
    #   {:ok, pid}
    # else
    #   IO.puts "registering new GenEvent"
    #   {:ok, pid} = GenEvent.start_link(opts)
    #   add_default_handler(display, pid)
    #   {:ok, pid}
    # end
    # pid = case GenEvent.start_link(opts) do
    #   {:ok, pid} -> pid
    #   {:error, {:already_started, pid}} -> IO.puts "using already started GenEvent"; pid
    # end
    # add_default_handler(display, pid)
    # {:ok, pid}
    # TODO cleanup this function
    {:ok, pid} = GenEvent.start_link(opts)
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
      :visual -> GenEvent.add_handler(pid, Elevator.VisualStatus, [])
    end
    pid
  end
end

