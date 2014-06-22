defmodule Elevator.Status do
  #use GenEvent #only need this when I'm ready for handle_event

  def start_link(opts \\ []) do
    #TODO change the env var for this name to display
    pid = case GenEvent.start_link(opts) do
      {:error, {:already_started, pid}} -> pid
      {:ok, pid} -> add_default_handler(pid)
    end
    {:ok, pid}
  end

  # def init(arg) do
  #   # I think the arg is the 3rd param to GenEvent.add_handler
  #   IO.inspect(arg)
  # end

  # def handle_event(event, state) do
  #   IO.inspect("received event #{event}")
  #   {:ok, state}
  # end

  defp add_default_handler(pid) do
    gen_event_name = Application.get_env(:elevator, :event_name)
    stream = GenEvent.stream(gen_event_name)
    #TODO expand this idea into an ansi terminal visual display
    spawn_link fn ->
      for {who, what, msg} <- stream do
        IO.puts "#{who} says #{what} and #{msg}"
      end
    end
    #GenEvent.add_handler(pid, __MODULE__, [])
    pid
  end
end
