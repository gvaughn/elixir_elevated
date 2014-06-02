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

  def handle_info(:timeout, state = %Car{floor: floor, heading: h}) when trunc(floor) == floor and h != 0 do
    # at a whole numbered floor
    log(state, :arrival, state.floor)
    {curr_calls, other_calls} = Enum.split_while(state.calls, &(&1.floor == state.floor))
    Enum.each(curr_calls, &(send(&1.caller, {:arrival, state.floor, self})))
    GenServer.call(:hall_signal, {:arrival, state.floor, state.heading})
    state = update_velocity(%{state | calls: other_calls})
    {:noreply, state, @timeout}
  end

  def handle_info(:timeout, state) do
    {:noreply, update_velocity(state), @timeout}
  end

  defp update_velocity(state = %Car{heading: 0, calls: []}) do
    case GenServer.call(:hall_signal, {:retrieve, state.floor, state.heading}) do
      :none  -> state #nowhere to go
      call   -> update_velocity(%{state | calls: [call | state.calls]})
    end
  end

  defp update_velocity(state = %Car{heading: 0}) do
    dest = List.first(state.calls)
    dir = Elevator.Call.dir(state.floor, dest.floor)
    new_floor = state.floor + 0.5*dir
    log(state, :transit, new_floor)
    %{state | heading: dir, floor: new_floor}
  end

  defp update_velocity(state = %Car{calls: []}), do: %{state | heading: 0}

  defp update_velocity(state) do
    dest = List.first(state.calls)
    new_floor = if dest.floor == (state.floor + 0.5*state.heading), do: dest.floor, else: state.floor + state.heading
    log(state, :transit, new_floor)
    %{state | floor: new_floor}
  end

  defp log(state, action, msg) do
    GenEvent.notify(:elevator_events, {:"elevator#{state.num}", action, msg})
  end
end
