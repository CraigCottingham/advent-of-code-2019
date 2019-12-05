defmodule AoC.Intcode.Interpreter.Spec do
  @moduledoc false

  use ESpec

  alias AoC.Intcode.Interpreter

  example_group "run/1" do
    context "parameter direct mode" do
      it "tests opcode 1 (add)" do
        Interpreter.initialize()
        |> Interpreter.set_memory([1, 0, 0, 0, 99])
        |> Interpreter.run()
        |> expect()
        |> to(eq([2, 0, 0, 0, 99]))

        Interpreter.initialize()
        |> Interpreter.set_memory([1, 5, 6, 7, 99, 2, 3, 0])
        |> Interpreter.run()
        |> expect()
        |> to(eq([1, 5, 6, 7, 99, 2, 3, 5]))
      end

      it "tests opcode 2 (multiply)" do
        Interpreter.initialize()
        |> Interpreter.set_memory([2, 3, 0, 3, 99])
        |> Interpreter.run()
        |> expect()
        |> to(eq([2, 3, 0, 6, 99]))

        Interpreter.initialize()
        |> Interpreter.set_memory([2, 5, 6, 7, 99, 2, 3, 0])
        |> Interpreter.run()
        |> expect()
        |> to(eq([2, 5, 6, 7, 99, 2, 3, 6]))
      end

      it "tests opcode 3 (input)" do
        Interpreter.initialize()
        |> Interpreter.set_memory([3, 3, 99, 0])
        |> Interpreter.set_input(fn -> 1 end)
        |> Interpreter.run()
        |> expect()
        |> to(eq([3, 3, 99, 1]))
      end

      it "tests opcode 4 (output)" do
      end
    end
  end
end
