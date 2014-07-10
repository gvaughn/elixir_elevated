defmodule Elevator.CarSupervisor do
  use Supervisor

  def start_link(params, opts \\[]) do
    Supervisor.start_link(__MODULE__, params, opts)
  end

  def init({bank_name, venue, hall_name, num_cars, tick}) do
    cars = for num <- 1..num_cars do
      id = {:Car, bank_name, num}
      worker(Elevator.Car, [{id, venue, hall_name, tick}], [id: id])
    end

    supervise(cars, strategy: :one_for_one)
  end

  def cast_all(bank, message) do
    sup_pid = Process.whereis(Elevator.BankSupervisor.car_supervisor(bank))
    case sup_pid do
      nil -> nil
      _   -> Task.async(cast_all_cars_impl(sup_pid, message))
    end
  end

  defp cast_all_cars_impl(sup_pid, message) do
    fn ->
      for {_id, pid, _type, _mod} <- Supervisor.which_children(sup_pid) do
        GenServer.cast(pid, message)
      end
    end
  end
end
