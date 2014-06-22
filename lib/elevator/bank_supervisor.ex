defmodule Elevator.BankSupervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, [])
  end

  def init(_) do
    gen_event_name = Application.get_env(:elevator, :event_name)
    # TODO consider calling the :event_name env var a venue (place of events)
    GenEvent.start_link(name: gen_event_name)
    stream = GenEvent.stream(gen_event_name)
    #TODO expand this idea into an ansi terminal visual display
    spawn_link fn ->
      for {who, what, msg} <- stream do
        IO.puts "#{who} says #{what} and #{msg}"
      end
    end
    num_cars = Application.get_env(:elevator, :num_cars)
    hall_name = Application.get_env(:elevator, :hall_name)

    dependants = [
      #TODO GenEvent
      worker(Elevator.HallSignal, [[name: hall_name]]), # TODO don't hardcode the supervisor's name, or base it upon the bank name
      supervisor(Elevator.CarSupervisor, [num_cars, [name: :car_supervisor]])
    ]

    supervise(dependants, strategy: :one_for_all)
  end
end
