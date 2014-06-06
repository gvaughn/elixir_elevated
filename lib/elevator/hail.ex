defmodule Elevator.Hail do
  alias __MODULE__
  defstruct dir: 1, floor: 1, caller: nil

  def best_match(hails, %Hail{floor: floor, dir: 0}) do
    farthest(hails, floor) |> List.first
  end

  def best_match(hails, %Hail{floor: floor, dir: dir}) do
   Enum.filter(hails, &(&1.dir == dir)) |> nearest(floor) |> List.first
  end

  def add_hail(hails, current_floor, new_floor, caller) do
    add_hail(hails, %Hail{dir: dir(current_floor, new_floor), floor: new_floor, caller: caller})
  end

  def add_hail(hails, nil), do: hails

  def add_hail(hails = [], hail) do
    [hail | hails]
  end

  def add_hail(hails, hail) do
    %Hail{floor: floor, dir: dir} = hd(hails)
    sort_by([hail | hails], dir, floor)
  end

  def split_by_floor(hails, floor) do
    Enum.partition(hails, &(&1.floor == floor))
  end

  def filter_by_hail(hails, hail) do
    Enum.filter(hails, &(&1.floor == hail.floor && &1.dir == hail.dir))
  end

  def next(hails, _dir) do
    #TODO woefully inadequete -- find nearest in given dir or nil if none in that dir
    List.first(hails)
  end

  #TODO an add method (or operator overload) to move from position to hail

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
    Enum.concat(nearest(same_dir, floor), farthest(other_dir, floor))
  end
end

