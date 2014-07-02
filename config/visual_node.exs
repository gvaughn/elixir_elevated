use Mix.Config

config :elevator,
  nodes: [:"bankA@GGV-LS"],
  banks: [
    [ name: "NONE",
      event_name: {:global, :elevator_events},
      display: :visual,
      tick: :infinity,
      num_cars: 0
    ]
  ]

