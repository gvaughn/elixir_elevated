use Mix.Config

config :elevator,
  banks: [
    [ name: "NONE",
      event_name: {:global, :elevator_events},
      display: :visual,
      tick: :infinity,
      num_cars: 0
    ]
  ]

