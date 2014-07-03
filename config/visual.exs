use Mix.Config

config :elevator,
  nodes: [:"velevator@GGV-LS"],
  banks: [
    [ name: "A",
      event_name: {:global, :elevator_events},
      display: :visual,
      tick: 1000,
      num_cars: 2
    ]
  ]

