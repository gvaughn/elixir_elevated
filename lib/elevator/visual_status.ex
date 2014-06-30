defmodule Elevator.VisualStatus do
  use GenEvent

  def init(_arg) do
    System.at_exit(fn(_) -> IO.puts "at_exit"; show_cursor end) #TODO not working
    # clear_screen
    # hide_cursor
    # draw []
    {:ok, %{}} #TODO state needs to keep track of cars and num of riders on them
  end

  # go_to events not needed for this visualization
  def handle_event({_ele, :go_to, _floor}, state), do: {:ok, state}
  # {:elevator1, :go_to, floor}

  # TODO don't use atom :elevator1
  def handle_event({:elevator1, _kind, floor}, state) do
    # {:elevator1, :arrival, floor}
    # {:elevator1, :transit, floor}
    # TODO distinguish with open/closed door sprite
    draw [car(:left, floor)]
    {:ok, state}
  end

  # TODO makes a person appear on the floor
  # {:hall_signal, :floor_call, floor}

  # TODO adds/removes rider from car
  # {:rider, :embark, floor}
  # {:rider, :disembark, floor}

  def handle_event(_event, state), do: {:ok, state}

  def terminate(_reason, _state) do
    show_cursor
    :ok
  end

  @num_floors 9
  @floor_height 3
  @building_x 20
  @building_y 10
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
   "║😃 ║",
   "┗━━┛"
   ]
  @car_width String.length(List.first(@car_sprite))
  @floor "\x{2560}" <> String.duplicate("\x{2550}", 10) <> "\x{2563}"
  @roof "\x{2560}" <> String.duplicate("\x{2568}", 10) <> "\x{2563}"
  @building_width String.length(@roof)

  def run do
    hide_cursor
    draw [car(:left, 7), car(:right, 2)]
    :timer.sleep 500
    draw [car(:left, 6), car(:right, 3)]
    :timer.sleep 500
    draw [car(:left, 5), car(:right, 4)]
    :timer.sleep 500
    draw [car(:left, 4), car(:right, 5)]
    :timer.sleep 500
    draw [car(:left, 3), car(:right, 6)]
    :timer.sleep 500
    draw [car(:left, 2), car(:right, 7)]
    IO.puts pos_at("", 1, 40) #move prompt out of way
    show_cursor
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
  defp hide_cursor,  do: IO.write "\e[?25l"
  defp show_cursor,  do: IO.write "\e[?25h"

  defp str(count), do: String.duplicate(" ", count)

  defp wall, do: "\x{254E}" <> str(10) <> "\x{254E}"
  defp wall(num), do: "\x{2551}" <> str(4) <> "#{num}\x{20E3}" <> str(5) <> "\x{2551}"

  defp floor(num), do: [wall(num), wall, @floor]
end
