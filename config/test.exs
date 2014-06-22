#override display so no noise in tests
use Mix.Config

config :elevator,
  display: :null
