defmodule AoC.Intcode.Interpreter.Spec do
  @moduledoc false

  use ESpec

  alias AoC.Intcode.Interpreter

  example_group "run/1" do
    context "parameter direct mode" do
      it "tests opcode 1 (add)" do
        [1, 0, 0, 0, 99]
        |> Interpreter.initialize()
        |> Interpreter.run()
        |> expect()
        |> to(eq([2, 0, 0, 0, 99]))

        [1, 5, 6, 7, 99, 2, 3, 0]
        |> Interpreter.initialize()
        |> Interpreter.run()
        |> expect()
        |> to(eq([1, 5, 6, 7, 99, 2, 3, 5]))
      end

      it "tests opcode 2 (multiply)" do
        [2, 3, 0, 3, 99]
        |> Interpreter.initialize()
        |> Interpreter.run()
        |> expect()
        |> to(eq([2, 3, 0, 6, 99]))

        [2, 5, 6, 7, 99, 2, 3, 0]
        |> Interpreter.initialize()
        |> Interpreter.run()
        |> expect()
        |> to(eq([2, 5, 6, 7, 99, 2, 3, 6]))
      end
    end
  end
end
