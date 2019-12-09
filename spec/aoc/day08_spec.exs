defmodule AoC.Day08.Spec do
  @moduledoc false

  use ESpec

  describe "sanity checks" do
    example_group "overlay/1" do
      it do
        expect(AoC.Day08.overlay([0, 1, 2, 0])) |> to(eq(0))
        expect(AoC.Day08.overlay([2, 1, 2, 0])) |> to(eq(1))
        expect(AoC.Day08.overlay([2, 2, 1, 0])) |> to(eq(1))
        expect(AoC.Day08.overlay([2, 2, 2, 0])) |> to(eq(0))
      end
    end

    example_group "split_into_layers/3" do
      it do
        input = "123456789012"
        width = 3
        height = 2

        expect(AoC.Day08.split_into_layers(input, width, height)) |> to(eq(["123456", "789012"]))
      end
    end
  end
end
