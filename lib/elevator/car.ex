# Crazy idea for long term expansion: change heading to a velocity. Can be greater if going a long distance
defmodule Elevator.Car do
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

  defp check_arrival(state) do
    {arrivals, rest} = Hail.split_by_floor(state.calls, state.pos.floor)
    if length(arrivals) > 0 do
      log(state, :arrival, state.pos.floor)
      GenServer.cast(:hall_signal, {:arrival, state.pos})
      Enum.each(arrivals, &(send(&1.caller, {:arrival, state.pos.floor, self})))
    end
    %{state | calls: rest}
  end

  defp move(state) do
    #TODO can this be achieved with a sort of add function (or overloaded operator)?
    new_dir  = new_dir(state.pos, Hail.next(state.calls, state.pos.dir))
    new_floor = state.pos.floor + new_dir
    if new_floor != state.pos.floor, do: log(state, :transit, new_floor)
    %{state | pos: %Hail{dir: new_dir, floor: new_floor}}
  end

  defp new_dir(_pos, nil), do: 0                                           #stop
  defp new_dir(pos = %Hail{dir: 0}, to), do: Hail.dir(pos.floor, to.floor) #start
  defp new_dir(pos, _to), do: pos.dir                                      #continue

  defp log(state, action, msg) do
    GenEvent.notify(:elevator_events, {:"elevator#{state.num}", action, msg})
  end
end
