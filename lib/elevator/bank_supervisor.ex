defmodule Elevator.BankSupervisor do
  use Supervisor

  def start_link(bank_def) do
    Supervisor.start_link(__MODULE__, bank_def, [name: :"Elevator.BankSupervisor-#{bank_def[:name]}"])
  end

  def init(bank_def) do
    bank_name = bank_def[:name]
    venue = bank_def[:event_name]
    display_type = bank_def[:display]
    num_cars = bank_def[:num_cars]
    hall_name = hall_signal(bank_name)
    tick = bank_def[:tick]

    dependants = [
      worker(Elevator.Status, [display_type, [name: venue]]),
      worker(Elevator.HallSignal, [venue, bank_name, [name: hall_name]]),
      supervisor(Elevator.CarSupervisor, [bank_name, venue, hall_name, num_cars, tick, [name: car_supervisor(bank_name)]])
    ]

    supervise(dependants, strategy: :rest_for_one)
  end

  def hall_signal(bank), do: :"Elevator.HallSignal-#{bank}"

  def car_supervisor(bank), do: :"Elevator.CarSupervisor-#{bank}"
end
