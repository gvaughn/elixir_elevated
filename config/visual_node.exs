use Mix.Config

config :elevator,
  banks: [
    [ name: "visual",
      event_name: {:global, :elevator_events},
      display: :visual,
      tick: :infinity,
      num_cars: 0
    ]
  ]

