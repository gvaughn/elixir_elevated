defmodule Elevator.Mixfile do
  use Mix.Project

  def project do
    [ app: :elevator,
      version: "0.0.1",
      elixir: "~> 0.14",
      deps: deps ]
  end

  # Configuration for the OTP application
  def application do
    [ applications: [],
      env: [event_name: nil, hall_name: nil, tick: nil, num_cars: nil], #doc required config.exs entries
      mod: { Elevator, [] }
    ]
  end

  defp deps do
    []
  end
end
