#override display so no noise in tests
use Mix.Config

config :elevator,
  banks: [
    [ name: "A",
      event_name: :elevator_events,
      display: :null,
      tick: 1000,
      num_cars: 1
    ]
  ]
