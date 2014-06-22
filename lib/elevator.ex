defmodule Elevator do
  use Application

  def start(_type, _args) do
    Elevator.Supervisor.start_link
  end

  def floor_call(from_floor, dir, rider_pid) do
    Elevator.HallSignal.floor_call(from_floor, dir, rider_pid)
  end

  def stop do
    Application.stop(:elevator)
  end

  def travel(from_floor, to_floor) do
    floor_call(from_floor, Elevator.Hail.dir(from_floor, to_floor), spawn(rider_fn(from_floor, to_floor)))
  end

  def test, do: Enum.each([{1,3}, {4,2}], fn{from, to} -> travel(from, to) end)

  defp rider_fn(from_floor, to_floor) do
    notifyee = Application.get_env(:elevator, :event_name)
    fn ->
      receive do
        {:arrival, ^from_floor, elevator_pid} ->
          GenEvent.notify(notifyee, {:rider, :embark, from_floor})
          Elevator.Car.go_to(elevator_pid, to_floor, self)
      end
      receive do
        {:arrival, ^to_floor, _} ->
          GenEvent.notify(notifyee, {:rider, :disembark, to_floor})
      end
    end
  end
end
