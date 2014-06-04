# Crazy idea for long term expansion: change heading to a velocity. Can be greater if going a long distance
defmodule Elevator.Car do
  alias __MODULE__
  alias Elevator.Hail
  use GenServer

  defstruct pos: %Hail{dir: 0, floor: 1}, calls: [], num: 0
  # heading(-1, 0, 1)
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
    new_calls = Elevator.Hail.add_call(state.calls, state.pos.floor, dest, caller)
    {:noreply, %{state | calls: new_calls}, @timeout}
  end

  def handle_info(:timeout, state) do
    {:noreply, state |> retrieve_call |> check_arrival |> move, @timeout}
  end

  defp retrieve_call(state) do
    case GenServer.call(:hall_signal, {:retrieve, state.pos}) do
      :none  -> state
      call   -> %{state | calls: [call | state.calls]} #TODO use sorting function in Hail
    end
  end

  defp check_arrival(state = %Car{pos: %Hail{floor: floor}}) when trunc(floor) == floor do
    floor = trunc(floor) #recipients expect integer
    #TODO this split behavior should be in Hail so it can resort
    {curr_calls, other_calls} = Enum.split_while(state.calls, &(&1.floor == floor))
    if length(curr_calls) > 0 do
      log(state, :arrival, floor)
      GenServer.call(:hall_signal, {:arrival, floor, state.pos.dir})
      Enum.each(curr_calls, &(send(&1.caller, {:arrival, floor, self})))
    end
    %{state | calls: other_calls}
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
