defmodule Elevator.Hail do
  alias __MODULE__
  defstruct dir: 1, floor: 1, caller: nil

  def create(from_floor, to_floor, caller) do
    %__MODULE__{dir: dir(from_floor, to_floor), floor: to_floor, caller: caller}
  end

  def best_match(hails, %Hail{floor: floor, dir: dir}) do
    #TODO refactor me need to find better match that just first
    List.first(hails)
  end

  def add_hail(hails, current_floor, new_floor, caller) do
    new_hails = create(current_floor, new_floor, caller)
    #TODO add some sorting before return
    [new_hails | hails]
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

  def next(hails, dir) do
    #TODO woefully inadequete -- find nearest in given dir
    List.first(hails)
  end

  def dir(floor, floor), do: 0

  def dir(from_floor, to_floor) do
    delta = to_floor - from_floor
    trunc(delta / abs(delta))
  end
end

