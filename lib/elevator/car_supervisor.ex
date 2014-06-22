defmodule Elevator.CarSupervisor do
  use Supervisor

  def start_link(num_cars, opts \\[]) do
    Supervisor.start_link(__MODULE__, num_cars, opts)
  end

  def init(num_cars) do
    gen_event_name = Application.get_env(:elevator, :event_name)
    hall_name = Application.get_env(:elevator, :hall_name)
    tick = Application.get_env(:elevator, :tick)
    cars = Enum.map(1..num_cars, &(
      worker(Elevator.Car, [{&1, gen_event_name, hall_name, tick}], [id: "Elevator.Car-#{&1}"])
    ))

    supervise(cars, strategy: :one_for_one)
  end
end
