defmodule Dxf do
  @moduledoc """
  Documentation for `Dxf`.
  """

  def read_dxf(filename) do
    File.read!(filename)
    |> String.split("\n")
    |> Enum.map(&String.split(&1," "))
    |> Enum.map(&Enum.reject(&1, fn x -> x == "" end))
    |> Enum.filter(&(&1 != []))
    |> Enum.map(&Enum.map(&1, fn x -> String.to_integer(x) end))
  end

  def set_map(content) do
    [head | tail] = content
    [dots,lines,triangles] = head
    dot_map = 
    for i <- 1..dots do
      %{dot_id: i, x: Enum.at(Enum.at(tail,i-1),0),y: Enum.at(Enum.at(tail,i-1),1), z: Enum.at(Enum.at(tail,i-1),2)}
    end
    line_map = 
    for j <- 1..lines do
      %{line_id: j, start: Enum.find(dot_map, & (&1.dot_id == Enum.at(Enum.at(tail,j+dots-1),0))),stop: Enum.find(dot_map, &(&1.dot_id ==Enum.at(Enum.at(tail,j+dots-1),1)))}
    end
    triangle_map = 
    for k <- 1..triangles do
      %{triangle_id: k, line_1: Enum.find(line_map, & (&1.line_id == Enum.at(Enum.at(tail,k+lines+dots-1),0))),line_2: Enum.find(line_map, & (&1.line_id == Enum.at(Enum.at(tail,k+lines+dots-1),1))), line_3: Enum.find(line_map, & (&1.line_id == Enum.at(Enum.at(tail,k+lines+dots-1),2)))}
    end
    triangle_map
  end

  def make_json(content) do
    [head | tail] = content
    [dots,lines,triangles] = head
    dot_map = 
    for i <- 1..dots do
      %{dot_id: i, x: Enum.at(Enum.at(tail,i-1),0),y: Enum.at(Enum.at(tail,i-1),1), z: Enum.at(Enum.at(tail,i-1),2),json:
      "{\n\t\t\t\"dot_id\": #{i},\n\t\t\t \"x\": #{Enum.at(Enum.at(tail,i-1),0)},\n\t\t\t \"y\": #{Enum.at(Enum.at(tail,i-1),1)},\n\t\t\t \"z\": #{Enum.at(Enum.at(tail,i-1),2)}\n\t\t}"}
    end
    line_map = 
    for j <- 1..lines do
      %{line_id: j, start: Map.to_list(Enum.find(dot_map, & (&1.dot_id == Enum.at(Enum.at(tail,j+dots-1),0)))),stop: Map.to_list(Enum.find(dot_map, &(&1.dot_id ==Enum.at(Enum.at(tail,j+dots-1),1)))),
    json: "{\n\t\t\"line_id\": #{j},\n\t\t \"start\": #{Map.get(Enum.find(dot_map, & (&1.dot_id == Enum.at(Enum.at(tail,j+dots-1),0))),:json)},\n\t\t \"stop\": #{Map.get(Enum.find(dot_map, &(&1.dot_id ==Enum.at(Enum.at(tail,j+dots-1),1))),:json)}\n\t}"}
    end
    triangle_map = 
    for k <- 1..triangles do
      %{triangle_id: k, line_1: Map.to_list(Enum.find(line_map, & (&1.line_id == Enum.at(Enum.at(tail,k+lines+dots-1),0)))),line_2: Map.to_list(Enum.find(line_map, & (&1.line_id == Enum.at(Enum.at(tail,k+lines+dots-1),1)))), line_3: Map.to_list(Enum.find(line_map, & (&1.line_id == Enum.at(Enum.at(tail,k+lines+dots-1),2)))),
    json: "{\n\t\"triangle_id\": #{k},\n\t \"line_1\": #{Map.get(Enum.find(line_map, & (&1.line_id == Enum.at(Enum.at(tail,k+lines+dots-1),0))),:json)},\n\t\"line_2\": #{Map.get(Enum.find(line_map, & (&1.line_id == Enum.at(Enum.at(tail,k+lines+dots-1),1))),:json)},\n\t \"line_3\": #{Map.get(Enum.find(line_map, & (&1.line_id == Enum.at(Enum.at(tail,k+lines+dots-1),2))),:json)}\n}"}
    end
    triangle_map
  end

  def main do
    filename = "cube.gts"
    map = read_dxf(filename)
    |> set_map()
    json = read_dxf(filename)
    |> make_json()

    
    IO.inspect(map,label: "map")
    Enum.each(json,&IO.puts(&1.json))
  end

  def map do
    filename = "cube.gts"
    map = read_dxf(filename)
    |> set_map()
    IO.inspect(map,label: "map")
  end

  def json do
    filename = "cube.gts"
    json = read_dxf(filename)
    |> make_json()

    Enum.each(json,&IO.puts(&1.json))
  end
end
