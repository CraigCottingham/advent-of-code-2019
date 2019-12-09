defmodule AoC.Day08 do
  @moduledoc false

  def part_1 do
    "data/day08-input.txt"
    |> load_image_data()
    |> Enum.map(fn pixels -> Enum.group_by(pixels, fn pixel -> pixel end) end)
    |> Enum.map(&reduce_to_pixel_count/1)
    |> Enum.min_by(&Map.get(&1, 0))
    |> (fn counts -> Map.get(counts, 1, 0) * Map.get(counts, 2, 0) end).()
  end

  def part_2 do
    "data/day08-input.txt"
    |> load_image_data()
    |> Enum.zip()
    |> Enum.map(&Tuple.to_list/1)
    |> Enum.map(&overlay/1)

    # ideally, we'd have some kind of character recognition here
    # for now, render out the image data, recognize it manually,
    # then return the text
    |> render(25, 6)

    "CYKBY"
  end

  def overlay(list), do: Enum.find(list, 2, &(&1 != 2))

  def split_into_layers(data, width, height), do: layer_splitter(data, [], width * height)

  defp layer_splitter("", acc, _), do: Enum.reverse(acc)

  defp layer_splitter(data, acc, length) do
    {layer, rest} = String.split_at(data, length)
    layer_splitter(rest, [layer | acc], length)
  end

  defp load_image_data(filename) do
    filename
    |> File.stream!()
    |> Enum.map(&String.trim/1)
    |> Enum.join()
    |> split_into_layers(25, 6)
    |> Enum.map(fn layer -> String.split(layer, "", trim: true) end)
    |> Enum.map(fn layer -> Enum.map(layer, &String.to_integer/1) end)
  end

  defp reduce_single_pixel_value({value, list}, acc), do: Map.put(acc, value, Enum.count(list))

  defp reduce_to_pixel_count(pixelmap),
    do: Enum.reduce(pixelmap, %{}, &reduce_single_pixel_value/2)

  defp render(data, width, height) do
    IO.puts("")

    for y <- 0..(height - 1) do
      for x <- 0..(width - 1) do
        pixel =
          case Enum.at(data, y * width + x) do
            1 -> "*"
            _ -> " "
          end

        IO.write(pixel)
      end

      IO.puts("")
    end
  end
end
