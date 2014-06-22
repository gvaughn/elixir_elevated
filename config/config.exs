# This file is responsible for configuring your application
# and its dependencies. The Mix.Config module provides functions
# to aid in doing so.
use Mix.Config

# Note this file is loaded before any dependency and is restricted
# to this project. If another project depends on this project, this
# file won't be loaded nor affect the parent project.

# Sample configuration:
#
#     config :my_dep,
#       key: :value,
#       limit: 42

# It is also possible to import configuration files, relative to this
# directory. For example, you can emulate configuration per environment
# by uncommenting the line below and defining dev.exs, test.exs and such.
# Configuration from the imported file will override the ones defined
# here (which is why it is important to import them last).
#
#     import_config "#{Mix.env}.exs"

# TODO OLDER VERSION OF THE ABOVE ADVICE? Cribbed from spoonbot github repo
# You can customize the configuration path by setting :config_path
# in your mix.exs file. For example, you can emulate configuration
# per environment by setting:
#
#    config_path: "config/#{Mix.env}.exs"

config :elevator,
  event_name: :elevator_events,
  hall_name: :hall_signal,
  tick: 1000,
  num_cars: 1

