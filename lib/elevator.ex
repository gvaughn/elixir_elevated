defmodule Elevator do
  use Application

  def start(_type, _args) do
    banks = Application.get_env(:elevator, :banks)
    if length(banks) == 1 do
      Elevator.BankSupervisor.start_link(List.first(banks))
    else
      #TODO need a master supervisor. This Application module could serve
      #Enum.each(banks, &Elevator.BankSupervisor.start_link(&1))
    end
  end

  def floor_call(from_floor, dir, rider_pid, bank \\ "A") do
    Elevator.HallSignal.floor_call(from_floor, dir, rider_pid, bank)
  end

  def stop do
    Application.stop(:elevator)
  end

  def travel(from_floor, to_floor) do
    floor_call(from_floor, Elevator.Hail.dir(from_floor, to_floor), spawn(rider_fn(from_floor, to_floor)))
  end

  def test, do: Enum.each([{1,3}, {4,2}], fn{from, to} -> travel(from, to) end)

  defp rider_fn(from_floor, to_floor) do
    #TODO no hardcode
    notifyee = :elevator_events
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
