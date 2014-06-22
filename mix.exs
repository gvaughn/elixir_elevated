defmodule Elevator.Mixfile do
  use Mix.Project

  def project do
    [ app: :elevator,
      version: "0.0.1",
      #elixir: "~> 0.10.2",
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

  # Returns the list of dependencies in the format:
  # { :foobar, "~> 0.1", git: "https://github.com/elixir-lang/foobar.git" }
  defp deps do
    [
      #{ :otp_dsl, github: "pragdave/otp_dsl" }
    ]
  end
end
