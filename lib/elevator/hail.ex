defmodule Elevator.Hail do
  alias __MODULE__
  defstruct dir: 1, floor: 1, caller: nil

  def best_match(hails, %Hail{floor: floor, dir: 0}) do
    current_floor = Enum.filter(hails, &(&1.floor == floor)) |> List.first
    current_floor || (farthest(hails, floor) |> List.first)
  end

  def best_match(hails, %Hail{floor: floor, dir: dir}) do
    Enum.filter(hails, &(&1.dir == dir)) |> nearest(floor) |> List.first
  end

  def split_by_floor(hails, floor) do
    Enum.partition(hails, &(&1.floor == floor))
  end

  def reject_matching(hails, hail) do
    Enum.reject(hails, &(&1.floor == hail.floor && &1.dir == hail.dir))
  end

  def move_toward(pos, nil), do: %{pos | dir: 0} #stop

  def move_toward(pos = %Hail{dir: 0}, dest) do #start
    new_dir = dir(pos.floor, dest.floor)
    %Hail{dir: new_dir, floor: pos.floor + new_dir}
  end

  def move_toward(pos, dest) do #continue
    if pos.dir != dir(pos.floor, dest.floor), do: IO.puts "WE SHOULDN'T GET HERE"
    %{pos | floor: pos.floor + pos.dir}
  end

  def dir(floor, floor), do: 0

  def dir(from_floor, to_floor) do
    delta = to_floor - from_floor
    trunc(delta / abs(delta))
  end

  defp nearest(hails, floor), do: Enum.sort(hails, &(abs(&1.floor - floor) < abs(&2.floor - floor)))

  defp farthest(hails, floor), do: Enum.sort(hails, &(abs(&1.floor - floor) > abs(&2.floor - floor)))

  defp sort_by(hails, 0, floor), do: nearest(hails, floor)

  defp sort_by(hails, dir, floor) do
    {same_dir, other_dir} = Enum.partition(hails, &(&1.dir == dir))
    Enum.concat(nearest(same_dir, floor), nearest(other_dir, floor))
  end
end

