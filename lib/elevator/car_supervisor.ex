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
end
