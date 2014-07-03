defmodule Elevator do
  use Application
  import Supervisor.Spec

  def start(_type, _args) do
    nodes = Application.get_env(:elevator, :nodes, [])
    for node <- nodes, do: Node.connect(node)
    if length(nodes) > 0, do: :global.sync

    bank_supervisors = Application.get_env(:elevator, :banks) |> Enum.map(&(
      supervisor(Elevator.BankSupervisor, [&1], [id: &1[:name]])
    ))
    Supervisor.start_link(bank_supervisors, strategy: :one_for_one)
  end

  def stop do
    Application.stop(:elevator)
  end

  def test, do: (for {from, to} <- [{1,3}, {4,2}], do: travel(from, to))

  def t do
    for _ <- 1..3, do: travel(:crypto.rand_uniform(1,10), :crypto.rand_uniform(1,10))
    :timer.sleep(:crypto.rand_uniform(7000, 10000))
    t
  end

  def travel(bank \\ "A", from_floor, to_floor) do
    dir = Elevator.Hail.dir(from_floor, to_floor)
    Elevator.HallSignal.floor_call(bank, from_floor, dir, spawn(rider_fn(bank, from_floor, to_floor)))
  end

  def venue_for_bank(bank) do
    bank = Enum.find(Application.get_env(:elevator, :banks), &(&1[:name] == bank))
    bank[:event_name]
  end

  defp rider_fn(bank, from_floor, to_floor) do
    notifyee = venue_for_bank(bank)
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
