defmodule Elevator.Hail do
  alias __MODULE__
  defstruct dir: 1, floor: 1, caller: nil

  def best_match(hails, %Hail{floor: floor, dir: dir}) do
    {same_dir, other_dir} = Enum.partition(hails, &(&1.dir == dir))
    subset = if length(same_dir) > 0, do: same_dir, else: other_dir
    subset |> Enum.sort(&(abs(&1.floor - floor) < abs(&2.floor - floor))) |> List.first
  end

  def add_hail(hails, current_floor, new_floor, caller) do
    add_hail(hails, %Hail{dir: dir(current_floor, new_floor), floor: new_floor, caller: caller})
  end

  def add_hail(hails, nil), do: hails

  def add_hail(hails, hail) do
    #TODO smarter sorted insert
    [hail | hails]
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

  def dir(floor, floor), do: 0

  def dir(from_floor, to_floor) do
    delta = to_floor - from_floor
    trunc(delta / abs(delta))
  end
end

