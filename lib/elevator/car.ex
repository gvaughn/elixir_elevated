# Crazy idea for long term expansion: change heading to a velocity. Can be greater if going a long distance
defmodule Elevator.Car do
  alias __MODULE__
  alias Elevator.Hail
  use GenServer

  defstruct pos: %Hail{dir: 0, floor: 1}, calls: [], num: 0
  @timeout 1000

  def start_link(num) do
    GenServer.start_link(__MODULE__, num, [])
  end

  def init(num) do
    # timeout could be a steady timer
    #  mostly if we want HallSignal to push calls to us
    #  as is, we're going to wait timeout after a rider is on and says :go_to
    #  which is not horrible in this simulation
    {:ok, %Elevator.Car{num: num}, @timeout}
  end

  # used once rider is on the elevator
  def go_to(pid, floor, caller) do
    GenServer.cast(pid, {:go_to, floor, caller})
  end

  # OTP handlers
  def handle_cast({:go_to, dest, caller}, state) do
    log(state, :go_to, dest)
    {:noreply, %{state | calls: Hail.add_hail(state.calls, state.pos.floor, dest, caller)}, @timeout}
  end

  def handle_info(:timeout, state) do
    {:noreply, state |> retrieve_call |> check_arrival |> move, @timeout}
  end

  defp retrieve_call(state) do
    new_hail = GenServer.call(:hall_signal, {:retrieve, state.pos})
    %{state | calls: Hail.add_hail(state.calls, new_hail)}
  end

  defp check_arrival(state = %Car{pos: %Hail{floor: floor}}) when trunc(floor) == floor do
    {arrivals, rest} = Hail.split_by_floor(state.calls, floor)
    if length(arrivals) > 0 do
      log(state, :arrival, floor)
      GenServer.cast(:hall_signal, {:arrival, state.pos})
      Enum.each(arrivals, &(send(&1.caller, {:arrival, trunc(floor), self})))
    end
    %{state | calls: rest}
  end

  defp check_arrival(state), do: state

  defp move(state) do
    {dir, delta} = velocity(state.pos, List.first(state.calls))
    new_floor = state.pos.floor + dir*delta
    if new_floor != state.pos.floor, do: log(state, :transit, new_floor)
    %{state | pos: %Hail{dir: dir, floor: new_floor}}
  end

  defp velocity(pos, to = nil), do: {0, pos.floor}

  defp velocity(pos = %Hail{dir: 0},  to) do
    {Elevator.Hail.dir(pos.floor, to.floor), 0.5}
  end

  defp velocity(pos, to) do
    {pos.dir, (if to.floor == pos.floor + 0.5*pos.dir, do: 0.5, else: 1)}
  end

  defp log(state, action, msg) do
    GenEvent.notify(:elevator_events, {:"elevator#{state.num}", action, msg})
  end
end
