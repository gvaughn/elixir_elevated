defmodule Elevator.BankSupervisor do
  use Supervisor

  def start_link do
    #TODO receive a bank id (A,B,C, etc) and hash of params
    # register self's name based upon bank
    # hall_name can be derived from bank, and Car's have prefix to name
    Supervisor.start_link(__MODULE__, [])
  end

  def init(_) do
    gen_event_name = Application.get_env(:elevator, :event_name)
    display_type = Application.get_env(:elevator, :display)
    num_cars = Application.get_env(:elevator, :num_cars)
    hall_name = Application.get_env(:elevator, :hall_name)

    dependants = [
      worker(Elevator.Status, [display_type, [name: gen_event_name]]),
      worker(Elevator.HallSignal, [[name: hall_name]]),
      # TODO don't hardcode the supervisor's name -- base it upon the bank name
      supervisor(Elevator.CarSupervisor, [num_cars, [name: :car_supervisor]])
    ]

    supervise(dependants, strategy: :one_for_all)
  end
end
