defmodule AoC.Day16.Spec do
  @moduledoc false

  use ESpec

  describe "sanity checks" do
  end

  example_group "checksum/2" do
    it do
      cs =
        "80871224585914546619083218645595"
        |> AoC.Day16.split_signal()
        |> AoC.Day16.checksum(100)

      expect(cs) |> to(eq(24_176_176))
    end

    it do
      cs =
        "19617804207202209144916044189917"
        |> AoC.Day16.split_signal()
        |> AoC.Day16.checksum(100)

      expect(cs) |> to(eq(73_745_418))
    end

    it do
      cs =
        "69317163492948606335995924319873"
        |> AoC.Day16.split_signal()
        |> AoC.Day16.checksum(100)

      expect(cs) |> to(eq(52_432_133))
    end
  end

  example_group "dither_signal/1" do
    it(
      do:
        expect(AoC.Day16.dither_signal([1, 2, 3, 4, 5, 6, 7, 8]))
        |> to(eq([4, 8, 2, 2, 6, 1, 5, 8]))
    )
  end

  example_group "embedded_message_offset/1" do
    it do
      offset =
        "03036732577212944063491565474664"
        |> AoC.Day16.split_signal()
        |> AoC.Day16.embedded_message_offset()

      expect(offset) |> to(eq(303_673))
    end
  end

  example_group "extract_embedded_image/1" do
    it do
      one_instance = AoC.Day16.split_signal("03036732577212944063491565474664")
      expect(AoC.Day16.extract_embedded_message(one_instance)) |> to(eq(84_462_026))
    end

    it do
      one_instance = AoC.Day16.split_signal("02935109699940807407585447034323")
      expect(AoC.Day16.extract_embedded_message(one_instance)) |> to(eq(78_725_270))
    end

    it do
      one_instance = AoC.Day16.split_signal("03081770884921959731165446850517")
      expect(AoC.Day16.extract_embedded_message(one_instance)) |> to(eq(53_553_731))
    end
  end

  example_group "get_dither_pattern/1" do
    it "when offset == 0" do
      pattern = AoC.Day16.get_dither_pattern(0)
      expect(Enum.take(pattern, 8)) |> to(eq([1, 0, -1, 0, 1, 0, -1, 0]))
    end

    it "when offset == 1" do
      pattern = AoC.Day16.get_dither_pattern(1)
      expect(Enum.take(pattern, 8)) |> to(eq([1, 0, -1, 0, 1, 0, -1, 0]))
    end

    it "when offset == 2" do
      pattern = AoC.Day16.get_dither_pattern(2)
      expect(Enum.take(pattern, 15)) |> to(eq([0, 1, 1, 0, 0, -1, -1, 0, 0, 1, 1, 0, 0, -1, -1]))
    end
  end

  example_group "split_signal/1" do
    it(do: expect(AoC.Day16.split_signal("15243")) |> to(eq([1, 5, 2, 4, 3])))
  end
end
