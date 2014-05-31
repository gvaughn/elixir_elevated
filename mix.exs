defmodule Elevator.Mixfile do
  use Mix.Project

  #@num_elevators 2
  @num_elevators 1

  def project do
    [ app: :elixir_elevated,
      version: "0.0.1",
      #elixir: "~> 0.10.2",
      deps: deps ]
  end

  # Configuration for the OTP application
  def application do
    [mod: { Elevator, [@num_elevators] }]
  end

  # Returns the list of dependencies in the format:
  # { :foobar, "~> 0.1", git: "https://github.com/elixir-lang/foobar.git" }
  defp deps do
    [
      #{ :otp_dsl, github: "pragdave/otp_dsl" }
    ]
  end
end
