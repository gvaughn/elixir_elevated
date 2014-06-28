defmodule Elevator.CarSupervisor do
  use Supervisor

  def start_link(bank_name, venue, hall_name, num_cars, tick, opts \\[]) do
    Supervisor.start_link(__MODULE__, {bank_name, venue, hall_name, num_cars, tick}, opts)
  end

  def init({bank_name, venue, hall_name, num_cars, tick}) do
    cars = Enum.map(1..num_cars, &(
      worker(Elevator.Car, [{&1, venue, hall_name, tick}], [id: "Elevator.Car-#{bank_name}-#{&1}"])
    ))

    supervise(cars, strategy: :one_for_one)
  end

  def cast_all(bank, message) do
    sup_pid = Process.whereis(Elevator.BankSupervisor.car_supervisor(bank))
    case sup_pid do
      nil -> nil
      _   -> Task.async(cast_all_cars_impl(sup_pid, message))
    end
  end

  defp cast_all_cars_impl(pid, message) do
    fn ->
      Supervisor.which_children(pid) |> Enum.map(fn {_id, pid, _type, _module} ->
        GenServer.cast(pid, message)
      end)
    end
  end
end
