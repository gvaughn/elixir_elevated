# Crazy idea for long term expansion: change heading to a velocity. Can be greater if going a long distance
defmodule Elevator.Car do
  alias Elevator.Car
  use GenServer

  defstruct floor: 1, heading: 0, calls: [], num: 0
  # heading(-1, 0, 1)
  @timeout 1000

  def start_link(num) do
    GenServer.start_link(__MODULE__, num, [])
  end

  def init(num) do
    #TODO timeout could be a steady timer
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
    new_calls = Elevator.Call.add_call(state.calls, state.floor, dest, caller)
    {:noreply, %{state | calls: new_calls}, @timeout}
  end

  def handle_info(:timeout, state) do
    {:noreply, state |> retrieve_call |> check_arrival |> update_velocity, @timeout}
  end

  defp retrieve_call(state) do
    case GenServer.call(:hall_signal, {:retrieve, state.floor, state.heading}) do
      :none  -> state
      call   -> %{state | calls: [call | state.calls]}
    end
  end

  defp check_arrival(state = %Car{floor: floor}) when trunc(floor) == floor do
    floor = trunc(floor) #recipients expect integer
    {curr_calls, other_calls} = Enum.split_while(state.calls, &(&1.floor == floor))
    if length(curr_calls) > 0 do
      log(state, :arrival, floor)
      GenServer.call(:hall_signal, {:arrival, floor, state.heading})
      Enum.each(curr_calls, &(send(&1.caller, {:arrival, floor, self})))
    end
    %{state | calls: other_calls}
  end

  defp check_arrival(state), do: state

  defp update_velocity(state = %Car{calls: []}), do: %{state | heading: 0}

  defp update_velocity(state) do
    dest = List.first(state.calls)
    delta = if state.heading == 0 || dest.floor == (state.floor + 0.5*state.heading), do: 0.5, else: 1
    dir = if state.heading == 0 do
      Elevator.Call.dir(state.floor, dest.floor)
    else
      state.heading
    end
    new_floor = state.floor + dir*delta
    log(state, :transit, new_floor)
    %{state | floor: new_floor, heading: dir}
  end

  defp log(state, action, msg) do
    GenEvent.notify(:elevator_events, {:"elevator#{state.num}", action, msg})
  end
end
