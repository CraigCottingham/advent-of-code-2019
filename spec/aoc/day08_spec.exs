defmodule AoC.Day08.Spec do
  @moduledoc false

  use ESpec

  describe "sanity checks" do
    example_group "split_into_layers" do
      it do
        input = "123456789012"
        width = 3
        height = 2

        expect(AoC.Day08.split_into_layers(input, width, height)) |> to(eq(["123456", "789012"]))
      end
    end
  end
end
