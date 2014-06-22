defmodule Elevator.BankSupervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, [])
  end

  #TODO if we can use Supervisor.Specs in start_link, we should
  # perhaps with an extra CarSupervisor we can?
  def init(_) do
    gen_event_name = Application.get_env(:elevator, :event_name)
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
    tick = Application.get_env(:elevator, :tick)
    cars = Enum.map(1..num_cars, &(worker(Elevator.Car, [{&1, gen_event_name, hall_name, tick}], [id: "Elevator.Car-#{&1}"])))
    signal = worker(Elevator.HallSignal, [[name: hall_name]])

    supervise([signal | cars], strategy: :one_for_one)
  end
end
