use Mix.Config

# Note this file is loaded before any dependency and is restricted
# to this project. If another project depends on this project, this
# file won't be loaded nor affect the parent project.


config :elevator,
  banks: [
    [ name: "A",
      event_name: :elevator_events,
      display: :stdout,
      tick: 1000,
      num_cars: 1
    ]
  ]

import_config "#{Mix.env}.exs"
