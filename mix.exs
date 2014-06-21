defmodule Elevator.Mixfile do
  use Mix.Project

  @config %{event_name: :elevator_events, hall_name: :hall_signal, tick: 1000, num_elevators: 1}
  #TODO use config.exs Mix.Config; use MIX_ENV to have mix merge that into app env

  def project do
    [ app: :elevator,
      version: "0.0.1",
      #elixir: "~> 0.10.2",
      deps: deps ]
  end

  # Configuration for the OTP application
  def application do
    [mod: { Elevator, @config }]
  end

  # Returns the list of dependencies in the format:
  # { :foobar, "~> 0.1", git: "https://github.com/elixir-lang/foobar.git" }
  defp deps do
    [
      #{ :otp_dsl, github: "pragdave/otp_dsl" }
    ]
  end
end
