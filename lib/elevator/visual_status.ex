defmodule Elevator.VisualStatus do
  use GenEvent

  def init(_arg) do
    {:ok, %{}}
  end

  # go_to events not needed for this visualization
  def handle_event({_ele, :go_to, _floor}, state), do: {:ok, state}
  # {:elevator1, :go_to, floor}

  def handle_event({car = {:Car, _bank, _num}, _kind, floor}, state) do
    # {:elevator1, :arrival, floor}
    # {:elevator1, :transit, floor}
    # TODO distinguish with open/closed door sprite
    state = Dict.put(state, car, floor)
    draw(state)
    {:ok, state}
  end

  # TODO makes a person appear on the floor
  # TODO needs more info to know the direction
  # {:hall_signal, :floor_call, floor}

  # TODO adds/removes rider from car
  # {:rider, :embark, floor}
  # {:rider, :disembark, floor}

  def handle_event(_event, state), do: {:ok, state}

  @num_floors 9
  @floor_height 3
  @building_x 20
  @building_y 10
  @car_sprite [
   "╭┻┻╮",
   "║😃 ║",
   "┗━━┛"
   ]
  @car_sprite2 """
  \x{256D}\x{253B}\x{253B}\x{256E}
  \x{2503}\x{1F601} \x{2551}
  \x{2517}\x{2501}\x{2501}\x{251B}
  """
  @car_width String.length(List.first(@car_sprite))
  @floor "\x{2560}" <> String.duplicate("\x{2550}", 10) <> "\x{2563}"
  @roof "\x{2560}" <> String.duplicate("\x{2568}", 10) <> "\x{2563}"
  @building_width String.length(@roof)

  defp draw(state = %{}) do
    sprites = for {{:Car, _, num}, floor} <- state do
      case num do
        1 -> car(:left, floor)
        2 -> car(:right, floor)
        _ -> ""
      end
    end
    draw(sprites)
  end

  defp draw(sprites) do
    clear_screen
    static = building(@num_floors) |> pos_at(@building_x, @building_y)
    IO.write [static | sprites]
    IO.puts pos_at("", 1, 40) #move prompt out of way
  end

  defp car(:left, floor) do
    car_x = 1 + @building_x - @car_width
    car_y = 1 + @building_y + (@num_floors - floor) * @floor_height
    pos_at(@car_sprite, car_x, car_y)
  end

  defp car(:right, floor) do
    car_x = @building_x + @building_width - 1
    car_y = 1 + @building_y + (@num_floors - floor) * @floor_height
    pos_at(@car_sprite, car_x, car_y)
  end

  defp building(count) do
    [@roof | count..1 |> Enum.map(&floor(&1)) |> List.flatten ]
  end

  defp pos_at(sprite, x, start_y) when is_list(sprite) do
    {res, _} = Enum.map_reduce(sprite, start_y, fn(row, y) ->
      {pos_at(row, x, y), y+1}
    end)
    res |> Enum.join("")
  end
  defp pos_at(str, x, y), do: "\e[#{y};#{x}H#{str}"

  defp clear_screen, do: IO.write "\e[2J"

  defp str(count), do: String.duplicate(" ", count)

  defp wall, do: "\x{254E}" <> str(10) <> "\x{254E}"
  defp wall(num), do: "\x{2551}" <> str(4) <> "#{num}\x{20E3}" <> str(5) <> "\x{2551}"

  defp floor(num), do: [wall(num), wall, @floor]
end
