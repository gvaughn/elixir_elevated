defmodule Elevator.Status do
  use GenEvent

  def start_link(display, opts \\ []) do
    pid = case GenEvent.start_link(opts) do
      {:ok, pid} -> pid
      {:error, {:already_started, pid}} -> pid
    end
    add_default_handler(display, pid)
    {:ok, pid}
  end

  def init(_arg) do
    # arg is the 3rd param to GenEvent.add_handler
    {:ok, []}
  end

  def handle_event(event, state) do
    IO.inspect(event)
    {:ok, state}
  end

  defp add_default_handler(display, pid) do
    case display do
      :stdout -> GenEvent.add_handler(pid, __MODULE__, [])
      :null -> nil
      #TODO expand this idea into an ansi terminal visual display
    end
    pid
  end
end

defmodule Temp do
  @car_with_rider """
  ╭┻┻╮
  ┃😁 ║
  ┗━━┛
  """
  @car_with_rider2 """
  \x{256D}\x{253B}\x{253B}\x{256E}
  \x{2503}\x{1F601} \x{2551}
  \x{2517}\x{2501}\x{2501}\x{251B}
  """
  @car_sprite [
   "╭┻┻╮",
   "║😁 ║",
   "┗━━┛"
   ]

  @floor "\x{2560}" <> String.duplicate("\x{2550}", 10) <> "\x{2563}"
  @roof "\x{2560}" <> String.duplicate("\x{2568}", 10) <> "\x{2563}"

  def wall, do: "\x{254E}" <> str(10) <> "\x{254E}"
  def wall(num), do: "\x{2551}" <> str(4) <> "#{num}\x{20E3}" <> str(5) <> "\x{2551}"

  def floor(num), do: [wall(num), wall, @floor]

  @num_floors 9
  def draw do
    static = building(@num_floors) |> pos_at(20, 10)
    car = @car_sprite |> pos_at(17, 17)
    car2 = @car_sprite |> pos_at(31, 32)
    IO.puts [static, car, car2]
    IO.puts pos_at("", 1, 40) #move prompt out of way
  end

  #TODO function to get car's x,y given left/right and floor

  def building(count) do
    [@roof | count..1 |> Enum.map(&floor(&1)) |> List.flatten ]
  end

  defp pos_at(sprite, x, start_y) when is_list(sprite) do
    {res, _} = Enum.map_reduce(sprite, start_y, fn(row, y) ->
      {pos_at(row, x, y), y+1}
    end)
    res |> Enum.join("")
  end
  defp pos_at(str, x, y), do: "\e[#{y};#{x}H#{str}"

  defp str(count), do: String.duplicate(" ", count)
end
