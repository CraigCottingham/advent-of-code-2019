defmodule AoC.Intcode.Interpreter.Spec do
  @moduledoc false

  use ESpec

  alias AoC.Intcode.{Interpreter, Memory}

  ## TODO: add specs for parameter modes
  ## TODO: add specs for large integer support

  example_group "start/1" do
    it do
      vm = Task.async(Interpreter, :initialize, [%{memory: [1, 0, 0, 0, 99]}])
      Interpreter.start(vm)
      {:halt, %{state: :stopped, memory: memory}} = Task.await(vm)
      expect(Memory.read(memory, 0)) |> to(eq(2))
    end
  end

  example_group "set_output_fn/1" do
    it do
      {:ok, agent} = Agent.start_link(fn -> nil end)
      output_fn = fn value -> Agent.update(agent, fn _ -> value end) end

      vm = Task.async(Interpreter, :initialize, [%{memory: [104, 3, 99, 2]}])
      Interpreter.set_output_fn(vm, output_fn)
      Interpreter.start(vm)
      {:halt, %{state: :stopped}} = Task.await(vm)

      expect(Agent.get(agent, fn value -> value end)) |> to(eq(3))

      Agent.stop(agent)
    end
  end

  example_group "run/1" do
    context "opcode 1 (add)" do
      it "tests position mode" do
        memory = [1, 0, 0, 0, 99]
        vm = Task.async(Interpreter, :initialize, [%{state: :running, memory: memory}])
        {:halt, %{state: :stopped, memory: memory}} = Task.await(vm)
        expect(Memory.read(memory, 0)) |> to(eq(2))
      end

      it "tests immediate mode" do
        memory = [1101, 5, 6, 5, 99, 0]
        vm = Task.async(Interpreter, :initialize, [%{state: :running, memory: memory}])
        {:halt, %{state: :stopped, memory: memory}} = Task.await(vm)
        expect(Memory.read(memory, 5)) |> to(eq(11))
      end

      it "tests relative mode" do
        memory = [109, 1, 22201, 2, 3, -1, 99]
        vm = Task.async(Interpreter, :initialize, [%{state: :running, memory: memory}])
        {:halt, %{state: :stopped, memory: memory}} = Task.await(vm)
        expect(Memory.read(memory, 0)) |> to(eq(5))
      end
    end

    context "opcode 2 (multiply)" do
      it "tests position mode" do
        memory = [2, 3, 0, 3, 99]
        vm = Task.async(Interpreter, :initialize, [%{state: :running, memory: memory}])
        {:halt, %{state: :stopped, memory: memory}} = Task.await(vm)
        expect(Memory.read(memory, 3)) |> to(eq(6))
      end

      it "tests immediate mode" do
        memory = [1102, 5, 6, 5, 99, 0]
        vm = Task.async(Interpreter, :initialize, [%{state: :running, memory: memory}])
        {:halt, %{state: :stopped, memory: memory}} = Task.await(vm)
        expect(Memory.read(memory, 5)) |> to(eq(30))
      end

      it "tests relative mode" do
        memory = [109, 1, 22202, 2, 3, -1, 99]
        vm = Task.async(Interpreter, :initialize, [%{state: :running, memory: memory}])
        {:halt, %{state: :stopped, memory: memory}} = Task.await(vm)
        expect(Memory.read(memory, 0)) |> to(eq(6))
      end
    end

    context "opcode 3 (input)" do
      it "tests position mode" do
        memory = [3, 3, 99, 0]
        vm = Task.async(Interpreter, :initialize, [%{state: :running, memory: memory}])
        send(vm.pid, 1)
        {:halt, %{state: :stopped, memory: memory}} = Task.await(vm)
        expect(Memory.read(memory, 3)) |> to(eq(1))
      end

      it "tests relative mode" do
        memory = [109, 1, 203, 4, 99, 0]
        vm = Task.async(Interpreter, :initialize, [%{state: :running, memory: memory}])
        send(vm.pid, 1)
        {:halt, %{state: :stopped, memory: memory}} = Task.await(vm)
        expect(Memory.read(memory, 5)) |> to(eq(1))
      end
    end

    context "opcode 4 (output)" do
      it "tests position mode" do
        {:ok, agent} = Agent.start_link(fn -> nil end)
        output_fn = fn value -> Agent.update(agent, fn _ -> value end) end

        memory = [4, 3, 99, 2]

        vm =
          Task.async(Interpreter, :initialize, [
            %{state: :running, memory: memory, output_fn: output_fn}
          ])

        {:halt, %{state: :stopped}} = Task.await(vm)

        expect(Agent.get(agent, fn value -> value end)) |> to(eq(2))

        Agent.stop(agent)
      end

      it "tests immediate mode" do
        {:ok, agent} = Agent.start_link(fn -> nil end)
        output_fn = fn value -> Agent.update(agent, fn _ -> value end) end

        memory = [104, 3, 99, 2]

        vm =
          Task.async(Interpreter, :initialize, [
            %{state: :running, memory: memory, output_fn: output_fn}
          ])

        {:halt, %{state: :stopped}} = Task.await(vm)

        expect(Agent.get(agent, fn value -> value end)) |> to(eq(3))

        Agent.stop(agent)
      end

      it "tests relative mode" do
        {:ok, agent} = Agent.start_link(fn -> nil end)
        output_fn = fn value -> Agent.update(agent, fn _ -> value end) end

        memory = [109, 4, 204, 1, 99, 2]

        vm =
          Task.async(Interpreter, :initialize, [
            %{state: :running, memory: memory, output_fn: output_fn}
          ])

        {:halt, %{state: :stopped}} = Task.await(vm)

        expect(Agent.get(agent, fn value -> value end)) |> to(eq(2))

        Agent.stop(agent)
      end
    end

    context "opcode 5 (jump-if-true)" do
      it "tests happy path (input == 2), position mode" do
        {:ok, agent} = Agent.start_link(fn -> nil end)
        output_fn = fn value -> Agent.update(agent, fn _ -> value end) end

        memory = [3, 13, 5, 13, 14, 1101, 0, 0, 12, 4, 12, 99, 1, -1, 9]

        vm =
          Task.async(Interpreter, :initialize, [
            %{state: :running, memory: memory, output_fn: output_fn}
          ])

        send(vm.pid, 1)
        {:halt, %{state: :stopped, memory: memory}} = Task.await(vm)

        expect(Agent.get(agent, fn value -> value end)) |> to(eq(1))
        expect(Memory.read(memory, 12)) |> to(eq(1))

        Agent.stop(agent)
      end

      it "tests happy path (input == 2), immediate mode" do
        {:ok, agent} = Agent.start_link(fn -> nil end)
        output_fn = fn value -> Agent.update(agent, fn _ -> value end) end

        memory = [3, 3, 1105, -1, 9, 1101, 0, 0, 12, 4, 12, 99, 1]

        vm =
          Task.async(Interpreter, :initialize, [
            %{state: :running, memory: memory, output_fn: output_fn}
          ])

        send(vm.pid, 1)
        {:halt, %{state: :stopped, memory: memory}} = Task.await(vm)

        expect(Agent.get(agent, fn value -> value end)) |> to(eq(1))
        expect(Memory.read(memory, 12)) |> to(eq(1))
      end

      it "tests happy path (input == 2), relative mode" do
        {:ok, agent} = Agent.start_link(fn -> nil end)
        output_fn = fn value -> Agent.update(agent, fn _ -> value end) end

        memory = [109, 1, 3, 15, 2205, 14, 15, 1101, 0, 0, 12, 4, 15, 99, 1, -1, 11]

        vm =
          Task.async(Interpreter, :initialize, [
            %{state: :running, memory: memory, output_fn: output_fn}
          ])

        send(vm.pid, 1)
        {:halt, %{state: :stopped, memory: memory}} = Task.await(vm)

        expect(Agent.get(agent, fn value -> value end)) |> to(eq(1))
        expect(Memory.read(memory, 15)) |> to(eq(1))

        Agent.stop(agent)
      end

      it "tests unhappy path (input == 0), immediate mode" do
        {:ok, agent} = Agent.start_link(fn -> nil end)
        output_fn = fn value -> Agent.update(agent, fn _ -> value end) end

        memory = [3, 3, 1105, -1, 9, 1101, 0, 0, 12, 4, 12, 99, 1]

        vm =
          Task.async(Interpreter, :initialize, [
            %{state: :running, memory: memory, output_fn: output_fn}
          ])

        send(vm.pid, 0)
        {:halt, %{state: :stopped, memory: memory}} = Task.await(vm)

        expect(Agent.get(agent, fn value -> value end)) |> to(eq(0))
        expect(Memory.read(memory, 12)) |> to(eq(0))

        Agent.stop(agent)
      end
    end

    context "opcode 6 (jump-if-false)" do
      it "tests happy path (input == 0), position mode" do
        {:ok, agent} = Agent.start_link(fn -> nil end)
        output_fn = fn value -> Agent.update(agent, fn _ -> value end) end

        memory = [3, 12, 6, 12, 15, 1, 13, 14, 13, 4, 13, 99, -1, 0, 1, 9]

        vm =
          Task.async(Interpreter, :initialize, [
            %{state: :running, memory: memory, output_fn: output_fn}
          ])

        send(vm.pid, 0)
        {:halt, %{state: :stopped, memory: memory}} = Task.await(vm)

        expect(Agent.get(agent, fn value -> value end)) |> to(eq(0))
        expect(Memory.read(memory, 13)) |> to(eq(0))

        Agent.stop(agent)
      end

      it "tests happy path (input == 0), immediate mode" do
        {:ok, agent} = Agent.start_link(fn -> nil end)
        output_fn = fn value -> Agent.update(agent, fn _ -> value end) end

        memory = [3, 3, 1106, -1, 9, 1, 13, 14, 13, 4, 13, 99, -1, 0, 1, 9]

        vm =
          Task.async(Interpreter, :initialize, [
            %{state: :running, memory: memory, output_fn: output_fn}
          ])

        send(vm.pid, 0)
        {:halt, %{state: :stopped, memory: memory}} = Task.await(vm)

        expect(Agent.get(agent, fn value -> value end)) |> to(eq(0))
        expect(Memory.read(memory, 13)) |> to(eq(0))

        Agent.stop(agent)
      end

      it "tests happy path (input == 0), relative mode" do
        {:ok, agent} = Agent.start_link(fn -> nil end)
        output_fn = fn value -> Agent.update(agent, fn _ -> value end) end

        memory = [109, 1, 3, 14, 2206, 13, 16, 1, 15, 16, 15, 4, 15, 99, -1, 0, 1, 11]

        vm =
          Task.async(Interpreter, :initialize, [
            %{state: :running, memory: memory, output_fn: output_fn}
          ])

        send(vm.pid, 0)
        {:halt, %{state: :stopped, memory: memory}} = Task.await(vm)

        expect(Agent.get(agent, fn value -> value end)) |> to(eq(0))
        expect(Memory.read(memory, 15)) |> to(eq(0))

        Agent.stop(agent)
      end

      it "tests unhappy path (input == 2), immediate mode" do
        {:ok, agent} = Agent.start_link(fn -> nil end)
        output_fn = fn value -> Agent.update(agent, fn _ -> value end) end

        memory = [3, 3, 1106, -1, 9, 1, 13, 14, 13, 4, 13, 99, -1, 0, 1, 9]

        vm =
          Task.async(Interpreter, :initialize, [
            %{state: :running, memory: memory, output_fn: output_fn}
          ])

        send(vm.pid, 2)
        {:halt, %{state: :stopped, memory: memory}} = Task.await(vm)

        expect(Agent.get(agent, fn value -> value end)) |> to(eq(1))
        expect(Memory.read(memory, 13)) |> to(eq(1))

        Agent.stop(agent)
      end
    end

    context "opcode 7 (less than)" do
      it "tests happy path (input < 8), position mode" do
        {:ok, agent} = Agent.start_link(fn -> nil end)
        output_fn = fn value -> Agent.update(agent, fn _ -> value end) end

        memory = [3, 9, 7, 9, 10, 9, 4, 9, 99, -1, 8]

        vm =
          Task.async(Interpreter, :initialize, [
            %{state: :running, memory: memory, output_fn: output_fn}
          ])

        send(vm.pid, 7)
        {:halt, %{state: :stopped, memory: memory}} = Task.await(vm)

        expect(Agent.get(agent, fn value -> value end)) |> to(eq(1))
        expect(Memory.read(memory, 9)) |> to(eq(1))

        Agent.stop(agent)
      end

      it "tests happy path (input < 9), immediate mode" do
        {:ok, agent} = Agent.start_link(fn -> nil end)
        output_fn = fn value -> Agent.update(agent, fn _ -> value end) end

        memory = [3, 3, 1107, -1, 9, 3, 4, 3, 99]

        vm =
          Task.async(Interpreter, :initialize, [
            %{state: :running, memory: memory, output_fn: output_fn}
          ])

        send(vm.pid, 8)
        {:halt, %{state: :stopped, memory: memory}} = Task.await(vm)

        expect(Agent.get(agent, fn value -> value end)) |> to(eq(1))
        expect(Memory.read(memory, 3)) |> to(eq(1))

        Agent.stop(agent)
      end

      it "tests happy path (input < 10), relative mode" do
        {:ok, agent} = Agent.start_link(fn -> nil end)
        output_fn = fn value -> Agent.update(agent, fn _ -> value end) end

        memory = [109, 1, 3, 11, 22207, 10, 11, 10, 4, 11, 99, -1, 10]

        vm =
          Task.async(Interpreter, :initialize, [
            %{state: :running, memory: memory, output_fn: output_fn}
          ])

        send(vm.pid, 9)
        {:halt, %{state: :stopped, memory: memory}} = Task.await(vm)

        expect(Agent.get(agent, fn value -> value end)) |> to(eq(1))
        expect(Memory.read(memory, 11)) |> to(eq(1))

        Agent.stop(agent)
      end

      it "tests unhappy path (input >= 8)" do
        {:ok, agent} = Agent.start_link(fn -> nil end)
        output_fn = fn value -> Agent.update(agent, fn _ -> value end) end

        memory = [3, 9, 7, 9, 10, 9, 4, 9, 99, -1, 8]

        vm =
          Task.async(Interpreter, :initialize, [
            %{state: :running, memory: memory, output_fn: output_fn}
          ])

        send(vm.pid, 9)
        {:halt, %{state: :stopped, memory: memory}} = Task.await(vm)

        expect(Agent.get(agent, fn value -> value end)) |> to(eq(0))
        expect(Memory.read(memory, 9)) |> to(eq(0))

        Agent.stop(agent)
      end
    end

    context "opcode 8 (equals)" do
      it "tests happy path (input == 8), position mode" do
        {:ok, agent} = Agent.start_link(fn -> nil end)
        output_fn = fn value -> Agent.update(agent, fn _ -> value end) end

        memory = [3, 9, 8, 9, 10, 9, 4, 9, 99, -1, 8]

        vm =
          Task.async(Interpreter, :initialize, [
            %{state: :running, memory: memory, output_fn: output_fn}
          ])

        send(vm.pid, 8)
        {:halt, %{state: :stopped, memory: memory}} = Task.await(vm)

        expect(Agent.get(agent, fn value -> value end)) |> to(eq(1))
        expect(Memory.read(memory, 9)) |> to(eq(1))

        Agent.stop(agent)
      end

      it "tests happy path (input == 8), immediate mode" do
        {:ok, agent} = Agent.start_link(fn -> nil end)
        output_fn = fn value -> Agent.update(agent, fn _ -> value end) end

        memory = [3, 3, 1108, -1, 8, 3, 4, 3, 99]

        vm =
          Task.async(Interpreter, :initialize, [
            %{state: :running, memory: memory, output_fn: output_fn}
          ])

        send(vm.pid, 8)
        {:halt, %{state: :stopped, memory: memory}} = Task.await(vm)

        expect(Agent.get(agent, fn value -> value end)) |> to(eq(1))
        expect(Memory.read(memory, 3)) |> to(eq(1))

        Agent.stop(agent)
      end

      it "tests happy path (input == 10), relative mode" do
        {:ok, agent} = Agent.start_link(fn -> nil end)
        output_fn = fn value -> Agent.update(agent, fn _ -> value end) end

        memory = [109, 1, 3, 11, 22208, 10, 11, 10, 4, 11, 99, -1, 10]

        vm =
          Task.async(Interpreter, :initialize, [
            %{state: :running, memory: memory, output_fn: output_fn}
          ])

        send(vm.pid, 10)
        {:halt, %{state: :stopped, memory: memory}} = Task.await(vm)

        expect(Agent.get(agent, fn value -> value end)) |> to(eq(1))
        expect(Memory.read(memory, 11)) |> to(eq(1))

        Agent.stop(agent)
      end

      it "tests unhappy path (input != 8)" do
        {:ok, agent} = Agent.start_link(fn -> nil end)
        output_fn = fn value -> Agent.update(agent, fn _ -> value end) end

        memory = [3, 9, 8, 9, 10, 9, 4, 9, 99, -1, 8]

        vm =
          Task.async(Interpreter, :initialize, [
            %{state: :running, memory: memory, output_fn: output_fn}
          ])

        send(vm.pid, 7)
        {:halt, %{state: :stopped, memory: memory}} = Task.await(vm)

        expect(Agent.get(agent, fn value -> value end)) |> to(eq(0))
        expect(Memory.read(memory, 9)) |> to(eq(0))

        Agent.stop(agent)
      end
    end

    context "opcode 9 (adjust relative base)" do
      it do
        memory = [9, 3, 99, 1]
        vm = Task.async(Interpreter, :initialize, [%{state: :running, memory: memory}])
        {:halt, %{state: :stopped, rp: rp}} = Task.await(vm)
        expect(rp) |> to(eq(1))
      end
    end

    context "a complex example" do
      it "tests input < 8" do
        {:ok, agent} = Agent.start_link(fn -> nil end)
        output_fn = fn value -> Agent.update(agent, fn _ -> value end) end

        memory = [
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
        ]

        vm =
          Task.async(Interpreter, :initialize, [
            %{state: :running, memory: memory, output_fn: output_fn}
          ])

        send(vm.pid, 7)
        {:halt, %{state: :stopped}} = Task.await(vm)

        expect(Agent.get(agent, fn value -> value end) |> to(eq(999)))

        Agent.stop(agent)
      end

      it "tests input == 8" do
        {:ok, agent} = Agent.start_link(fn -> nil end)
        output_fn = fn value -> Agent.update(agent, fn _ -> value end) end

        memory = [
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
        ]

        vm =
          Task.async(Interpreter, :initialize, [
            %{state: :running, memory: memory, output_fn: output_fn}
          ])

        send(vm.pid, 8)
        {:halt, %{state: :stopped}} = Task.await(vm)

        expect(Agent.get(agent, fn value -> value end) |> to(eq(1000)))

        Agent.stop(agent)
      end

      it "tests input == 9" do
        {:ok, agent} = Agent.start_link(fn -> nil end)
        output_fn = fn value -> Agent.update(agent, fn _ -> value end) end

        memory = [
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
        ]

        vm =
          Task.async(Interpreter, :initialize, [
            %{state: :running, memory: memory, output_fn: output_fn}
          ])

        send(vm.pid, 9)
        {:halt, %{state: :stopped}} = Task.await(vm)

        expect(Agent.get(agent, fn value -> value end) |> to(eq(1001)))

        Agent.stop(agent)
      end
    end
  end
end
