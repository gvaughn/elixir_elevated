defmodule Elevator.Car do
  use GenServer
  alias __MODULE__
  alias Elevator.Hail

  defstruct pos: %Hail{dir: 0, floor: 1}, stops: [], hall: nil, tick: 0

  def start_link(init_params, opts \\ []) do
    GenServer.start_link(__MODULE__, init_params, opts)
  end

  def init({hall, tick}) do
    {:ok, %Car{hall: hall, tick: tick}, tick}
  end

  def go_to(pid, floor, caller) do
    GenServer.cast(pid, {:go_to, floor, caller})
  end

  def handle_cast({:go_to, dest, caller}, state) do
    log(state, :go_to, dest)
    new_hail = %Hail{floor: dest, caller: caller}
    {:noreply, add_hail(state, new_hail), state.tick}
  end

  def handle_info(:timeout, state) do
    {:noreply, state |> retrieve_call |> check_arrival |> move, state.tick}
  end

  def handle_info(_msg, state) do
    {:noreply, state}
  end

  defp retrieve_call(state) do
    new_hail = GenServer.call(state.hall, {:retrieve, state.pos})
    add_hail(state, new_hail)
  end

  defp check_arrival(state) do
    {arrivals, rest} = Enum.partition(state.stops, &(&1.floor == state.pos.floor))
    if length(arrivals) > 0 do
      log(state, :arrival, state.pos.floor)
      GenServer.cast(state.hall, {:arrival, state.pos})
      Enum.each(arrivals, &(send(&1.caller, {:arrival, state.pos.floor, self})))
      %{state | stops: Hail.sort(rest, state.pos)}
    else
      state
    end
  end

  defp move(state) do
    new_pos = Hail.move_toward(state.pos, List.first(state.stops))
    if new_pos.floor != state.pos.floor, do: log(state, :transit, new_pos.floor)
    %{state | pos: new_pos}
  end

  defp add_hail(state, nil), do: state
  defp add_hail(state = %Car{stops: []}, hail) do
    %{state | stops: [hail], pos: target(state.pos, hail)}
  end
  defp add_hail(state = %Car{stops: [head | rest]}, hail) do
    %{state | stops: Enum.uniq([head, hail | rest])}
  end

  defp target(pos, nil), do: pos
  defp target(pos, hail) do
    delta = hail.floor - pos.floor
    new_dir = if delta == 0, do: hail.dir, else: div(delta, abs(delta))
    %{pos | dir: new_dir}
  end

  defp log(_state, action, msg) do
    IO.puts "car #{action} #{msg}"
  end
end
