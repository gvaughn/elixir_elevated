# Crazy idea for long term expansion: change heading to a velocity. Can be greater if going a long distance
defmodule Elevator.Car do
  use GenServer
  alias __MODULE__
  alias Elevator.Hail

  # TODO rename pos to vector?
  defstruct pos: %Hail{dir: 0, floor: 1}, calls: [], num: 0, event: nil, hall: nil, tick: nil

  def start_link(params) do
    GenServer.start_link(__MODULE__, params, [])
  end

  def init(args = {num, event, hall, tick}) do
    # timeout could be a steady timer
    #  mostly if we want HallSignal to push calls to us
    #  as is, we're going to wait timeout after a rider is on and says :go_to
    #  which is not horrible in this simulation
    {:ok, %Elevator.Car{num: num, event: event, hall: hall, tick: tick}, tick}
  end

  # used once rider is on the elevator
  def go_to(pid, floor, caller) do
    GenServer.cast(pid, {:go_to, floor, caller})
  end

  # OTP handlers
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
    {arrivals, rest} = Enum.partition(state.calls, &(&1.floor == state.pos.floor))
    if length(arrivals) > 0 do
      log(state, :arrival, state.pos.floor)
      #TODO ensure HallSignal removes when state.pos.dir is 0
      GenServer.cast(state.hall, {:arrival, state.pos})
      Enum.each(arrivals, &(send(&1.caller, {:arrival, state.pos.floor, self})))
      #TODO sort rest
      %{state | calls: rest}
    else
      state
    end
  end

  defp move(state) do
    new_pos = Hail.move_toward(state.pos, List.first(state.calls))
    if new_pos.floor != state.pos.floor, do: log(state, :transit, new_pos.floor)
    %{state | pos: new_pos}
  end

  defp add_hail(state, nil), do: state
  defp add_hail(state = %Car{calls: []}, hail) do
    #TODO if we could avoid the update of pos and target call, we could move to Hail module
    %{state | calls: [hail], pos: target(state.pos, hail)}
  end
  # hail added to 2nd position of calls. Will be sorted later
  defp add_hail(state = %Car{calls: [head | rest]}, hail), do: %{state | calls: Enum.uniq([head, hail | rest])}

  defp target(pos, nil), do: pos
  defp target(pos, hail) do
    delta = hail.floor - pos.floor
    new_dir = if delta == 0, do: hail.dir, else: trunc(delta / abs(delta))
    %{pos | dir: new_dir}
  end

  defp log(state, action, msg) do
    GenEvent.notify(state.event, {:"elevator#{state.num}", action, msg})
  end
end
