defmodule AoC.Intcode.Interpreter.Spec do
  @moduledoc false

  use ESpec

  alias AoC.Intcode.{Interpreter, Memory}

  example_group "run/1" do
    context "opcode 1 (add)" do
      it "tests position mode" do
        Interpreter.initialize()
        |> Interpreter.set_memory([1, 0, 0, 0, 99])
        |> Interpreter.run()
        |> Memory.read(0)
        |> expect()
        |> to(eq(2))
      end

      it "tests immediate mode" do
        Interpreter.initialize()
        |> Interpreter.set_memory([1101, 5, 6, 5, 99, 0])
        |> Interpreter.run()
        |> Memory.read(5)
        |> expect()
        |> to(eq(11))
      end
    end

    context "opcode 2 (multiply)" do
      it "tests position mode" do
        Interpreter.initialize()
        |> Interpreter.set_memory([2, 3, 0, 3, 99])
        |> Interpreter.run()
        |> Memory.read(3)
        |> expect()
        |> to(eq(6))
      end

      it "tests immediate mode" do
        Interpreter.initialize()
        |> Interpreter.set_memory([1102, 5, 6, 5, 99, 0])
        |> Interpreter.run()
        |> Memory.read(5)
        |> expect()
        |> to(eq(30))
      end
    end

    context "opcode 3 (input)" do
      it do
        Interpreter.initialize()
        |> Interpreter.set_memory([3, 3, 99, 0])
        |> Interpreter.set_input(fn -> 1 end)
        |> Interpreter.run()
        |> Memory.read(3)
        |> expect()
        |> to(eq(1))
      end
    end

    context "opcode 4 (output)" do
      it "tests position mode" do
        {:ok, agent} = Agent.start_link(fn -> nil end)
        output_fn = fn value -> Agent.update(agent, fn _ -> value end) end

        Interpreter.initialize()
        |> Interpreter.set_memory([4, 3, 99, 2])
        |> Interpreter.set_output(output_fn)
        |> Interpreter.run()

        expect(Agent.get(agent, fn value -> value end) |> to(eq(2)))

        Agent.stop(agent)
      end

      it "tests immediate mode" do
        {:ok, agent} = Agent.start_link(fn -> nil end)
        output_fn = fn value -> Agent.update(agent, fn _ -> value end) end

        Interpreter.initialize()
        |> Interpreter.set_memory([104, 3, 99, 2])
        |> Interpreter.set_output(output_fn)
        |> Interpreter.run()

        expect(Agent.get(agent, fn value -> value end) |> to(eq(3)))

        Agent.stop(agent)
      end
    end

    context "opcode 5 (jump-if-true)" do
      it "tests happy path (input == 2), position mode" do
        input_fn = fn -> 1 end
        output_fn = fn value -> value end

        Interpreter.initialize()
        |> Interpreter.set_memory([3, 13, 5, 13, 14, 1101, 0, 0, 12, 4, 12, 99, 1, -1, 9])
        |> Interpreter.set_input(input_fn)
        |> Interpreter.set_output(output_fn)
        |> Interpreter.run()
        |> Memory.read(12)
        |> expect()
        |> to(eq(1))
      end

      it "tests happy path (input == 2), immediate mode" do
        input_fn = fn -> 1 end
        output_fn = fn value -> value end

        Interpreter.initialize()
        |> Interpreter.set_memory([3, 3, 1105, -1, 9, 1101, 0, 0, 12, 4, 12, 99, 1])
        |> Interpreter.set_input(input_fn)
        |> Interpreter.set_output(output_fn)
        |> Interpreter.run()
        |> Memory.read(12)
        |> expect()
        |> to(eq(1))
      end

      it "tests unhappy path (input == 0), immediate mode" do
        input_fn = fn -> 0 end
        output_fn = fn value -> value end

        Interpreter.initialize()
        |> Interpreter.set_memory([3, 3, 1105, -1, 9, 1101, 0, 0, 12, 4, 12, 99, 1])
        |> Interpreter.set_input(input_fn)
        |> Interpreter.set_output(output_fn)
        |> Interpreter.run()
        |> Memory.read(12)
        |> expect()
        |> to(eq(0))
      end
    end

    context "opcode 6 (jump-if-false)" do
      it "tests happy path (input == 0), position mode" do
        input_fn = fn -> 0 end
        output_fn = fn value -> value end

        Interpreter.initialize()
        |> Interpreter.set_memory([3, 12, 6, 12, 15, 1, 13, 14, 13, 4, 13, 99, -1, 0, 1, 9])
        |> Interpreter.set_input(input_fn)
        |> Interpreter.set_output(output_fn)
        |> Interpreter.run()
        |> Memory.read(13)
        |> expect()
        |> to(eq(0))
      end

      it "tests happy path (input == 0), immediate mode" do
        input_fn = fn -> 0 end
        output_fn = fn value -> value end

        Interpreter.initialize()
        |> Interpreter.set_memory([3, 3, 1106, -1, 9, 1, 13, 14, 13, 4, 13, 99, -1, 0, 1, 9])
        |> Interpreter.set_input(input_fn)
        |> Interpreter.set_output(output_fn)
        |> Interpreter.run()
        |> Memory.read(13)
        |> expect()
        |> to(eq(0))
      end

      it "tests unhappy path (input == 2), immediate mode" do
        input_fn = fn -> 2 end
        output_fn = fn value -> value end

        Interpreter.initialize()
        |> Interpreter.set_memory([3, 3, 1106, -1, 9, 1, 13, 14, 13, 4, 13, 99, -1, 0, 1, 9])
        |> Interpreter.set_input(input_fn)
        |> Interpreter.set_output(output_fn)
        |> Interpreter.run()
        |> Memory.read(13)
        |> expect()
        |> to(eq(1))
      end
    end

    context "opcode 7 (less than)" do
      it "tests happy path (input < 8), position mode" do
        input_fn = fn -> 0 end
        output_fn = fn value -> value end

        Interpreter.initialize()
        |> Interpreter.set_memory([3, 9, 7, 9, 10, 9, 4, 9, 99, -1, 8])
        |> Interpreter.set_input(input_fn)
        |> Interpreter.set_output(output_fn)
        |> Interpreter.run()
        |> Memory.read(9)
        |> expect()
        |> to(eq(1))
      end

      it "tests happy path (input < 8), immediate mode" do
        input_fn = fn -> 0 end
        output_fn = fn value -> value end

        Interpreter.initialize()
        |> Interpreter.set_memory([3, 3, 1107, -1, 8, 3, 4, 3, 99])
        |> Interpreter.set_input(input_fn)
        |> Interpreter.set_output(output_fn)
        |> Interpreter.run()
        |> Memory.read(3)
        |> expect()
        |> to(eq(1))
      end

      it "tests unhappy path (input >= 8)" do
        input_fn = fn -> 9 end
        output_fn = fn value -> value end

        Interpreter.initialize()
        |> Interpreter.set_memory([3, 9, 7, 9, 10, 9, 4, 9, 99, -1, 8])
        |> Interpreter.set_input(input_fn)
        |> Interpreter.set_output(output_fn)
        |> Interpreter.run()
        |> Memory.read(9)
        |> expect()
        |> to(eq(0))
      end
    end

    context "opcode 8 (equals)" do
      it "tests happy path (input == 8), position mode" do
        input_fn = fn -> 8 end
        output_fn = fn value -> value end

        Interpreter.initialize()
        |> Interpreter.set_memory([3, 9, 8, 9, 10, 9, 4, 9, 99, -1, 8])
        |> Interpreter.set_input(input_fn)
        |> Interpreter.set_output(output_fn)
        |> Interpreter.run()
        |> Memory.read(9)
        |> expect()
        |> to(eq(1))
      end

      it "tests happy path (input == 8), immediate mode" do
        input_fn = fn -> 8 end
        output_fn = fn value -> value end

        Interpreter.initialize()
        |> Interpreter.set_memory([3, 3, 1108, -1, 8, 3, 4, 3, 99])
        |> Interpreter.set_input(input_fn)
        |> Interpreter.set_output(output_fn)
        |> Interpreter.run()
        |> Memory.read(3)
        |> expect()
        |> to(eq(1))
      end

      it "tests unhappy path (input != 8)" do
        input_fn = fn -> 1 end
        output_fn = fn value -> value end

        Interpreter.initialize()
        |> Interpreter.set_memory([3, 9, 8, 9, 10, 9, 4, 9, 99, -1, 8])
        |> Interpreter.set_input(input_fn)
        |> Interpreter.set_output(output_fn)
        |> Interpreter.run()
        |> Memory.read(9)
        |> expect()
        |> to(eq(0))
      end
    end

    context "a complex example" do
      it "tests input < 8" do
        {:ok, agent} = Agent.start_link(fn -> nil end)
        input_fn = fn -> 7 end
        output_fn = fn value -> Agent.update(agent, fn _ -> value end) end

        Interpreter.initialize()
        |> Interpreter.set_memory([
          3,
          21,
          1008,
          21,
          8,
          20,
          1005,
          20,
          22,
          107,
          8,
          21,
          20,
          1006,
          20,
          31,
          1106,
          0,
          36,
          98,
          0,
          0,
          1002,
          21,
          125,
          20,
          4,
          20,
          1105,
          1,
          46,
          104,
          999,
          1105,
          1,
          46,
          1101,
          1000,
          1,
          20,
          4,
          20,
          1105,
          1,
          46,
          98,
          99
        ])
        |> Interpreter.set_input(input_fn)
        |> Interpreter.set_output(output_fn)
        |> Interpreter.run()

        expect(Agent.get(agent, fn value -> value end) |> to(eq(999)))

        Agent.stop(agent)
      end

      it "tests input == 8" do
        {:ok, agent} = Agent.start_link(fn -> nil end)
        input_fn = fn -> 8 end
        output_fn = fn value -> Agent.update(agent, fn _ -> value end) end

        Interpreter.initialize()
        |> Interpreter.set_memory([
          3,
          21,
          1008,
          21,
          8,
          20,
          1005,
          20,
          22,
          107,
          8,
          21,
          20,
          1006,
          20,
          31,
          1106,
          0,
          36,
          98,
          0,
          0,
          1002,
          21,
          125,
          20,
          4,
          20,
          1105,
          1,
          46,
          104,
          999,
          1105,
          1,
          46,
          1101,
          1000,
          1,
          20,
          4,
          20,
          1105,
          1,
          46,
          98,
          99
        ])
        |> Interpreter.set_input(input_fn)
        |> Interpreter.set_output(output_fn)
        |> Interpreter.run()

        expect(Agent.get(agent, fn value -> value end) |> to(eq(1000)))

        Agent.stop(agent)
      end

      it "tests input == 9" do
        {:ok, agent} = Agent.start_link(fn -> nil end)
        input_fn = fn -> 9 end
        output_fn = fn value -> Agent.update(agent, fn _ -> value end) end

        Interpreter.initialize()
        |> Interpreter.set_memory([
          3,
          21,
          1008,
          21,
          8,
          20,
          1005,
          20,
          22,
          107,
          8,
          21,
          20,
          1006,
          20,
          31,
          1106,
          0,
          36,
          98,
          0,
          0,
          1002,
          21,
          125,
          20,
          4,
          20,
          1105,
          1,
          46,
          104,
          999,
          1105,
          1,
          46,
          1101,
          1000,
          1,
          20,
          4,
          20,
          1105,
          1,
          46,
          98,
          99
        ])
        |> Interpreter.set_input(input_fn)
        |> Interpreter.set_output(output_fn)
        |> Interpreter.run()

        expect(Agent.get(agent, fn value -> value end) |> to(eq(1001)))

        Agent.stop(agent)
      end
    end
  end
end
