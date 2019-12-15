defmodule AoC.Day14.Spec do
  @moduledoc false

  use ESpec

  describe "sanity checks" do
    it "tests allowing ore to be borrowed" do
      all_reactions =
        [
          "9 ORE => 2 A",
          "8 ORE => 3 B",
          "7 ORE => 5 C",
          "3 A, 4 B => 1 AB",
          "5 B, 7 C => 1 BC",
          "4 C, 1 A => 1 CA",
          "2 AB, 3 BC, 4 CA => 1 FUEL"
        ]
        |> Enum.map(&AoC.Day14.parse_line/1)

      reaction = AoC.Day14.find_reaction(all_reactions, "FUEL")

      stockpile = AoC.Day14.run_reaction([reaction], %{}, true, all_reactions)
      expect(Map.get(stockpile, "ORE")) |> to(eq(165))
    end

    it "tests working with limited ore" do
      all_reactions =
        [
          "9 ORE => 2 A",
          "8 ORE => 3 B",
          "7 ORE => 5 C",
          "3 A, 4 B => 1 AB",
          "5 B, 7 C => 1 BC",
          "4 C, 1 A => 1 CA",
          "2 AB, 3 BC, 4 CA => 1 FUEL"
        ]
        |> Enum.map(&AoC.Day14.parse_line/1)

      reaction = AoC.Day14.find_reaction(all_reactions, "FUEL")

      stockpile = AoC.Day14.run_reaction([reaction], %{"ORE" => 166}, false, all_reactions)
      expect(Map.get(stockpile, "ORE")) |> to(eq(1))
    end

    xit do
      all_reactions =
        [
          "157 ORE => 5 NZVS",
          "165 ORE => 6 DCFZ",
          "44 XJWVT, 5 KHKGT, 1 QDVJ, 29 NZVS, 9 GPVTF, 48 HKGWZ => 1 FUEL",
          "12 HKGWZ, 1 GPVTF, 8 PSHF => 9 QDVJ",
          "179 ORE => 7 PSHF",
          "177 ORE => 5 HKGWZ",
          "7 DCFZ, 7 PSHF => 2 XJWVT",
          "165 ORE => 2 GPVTF",
          "3 DCFZ, 7 NZVS, 5 HKGWZ, 10 PSHF => 8 KHKGT"
        ]
        |> Enum.map(&AoC.Day14.parse_line/1)

      reaction = AoC.Day14.find_reaction(all_reactions, "FUEL")

      stockpile = AoC.Day14.run_reaction([reaction], %{}, true, all_reactions)
      expect(Map.get(stockpile, "ORE")) |> to(eq(13312))
    end

    xit do
      all_reactions =
        [
          "2 VPVL, 7 FWMGM, 2 CXFTF, 11 MNCFX => 1 STKFG",
          "17 NVRVD, 3 JNWZP => 8 VPVL",
          "53 STKFG, 6 MNCFX, 46 VJHF, 81 HVMC, 68 CXFTF, 25 GNMV => 1 FUEL",
          "22 VJHF, 37 MNCFX => 5 FWMGM",
          "139 ORE => 4 NVRVD",
          "144 ORE => 7 JNWZP",
          "5 MNCFX, 7 RFSQX, 2 FWMGM, 2 VPVL, 19 CXFTF => 3 HVMC",
          "5 VJHF, 7 MNCFX, 9 VPVL, 37 CXFTF => 6 GNMV",
          "145 ORE => 6 MNCFX",
          "1 NVRVD => 8 CXFTF",
          "1 VJHF, 6 MNCFX => 4 RFSQX",
          "176 ORE => 6 VJHF"
        ]
        |> Enum.map(&AoC.Day14.parse_line/1)

      reaction = AoC.Day14.find_reaction(all_reactions, "FUEL")

      stockpile = AoC.Day14.run_reaction([reaction], %{}, true, all_reactions)
      expect(Map.get(stockpile, "ORE")) |> to(eq(180_697))
    end

    xit do
      all_reactions =
        [
          "171 ORE => 8 CNZTR",
          "7 ZLQW, 3 BMBT, 9 XCVML, 26 XMNCP, 1 WPTQ, 2 MZWV, 1 RJRHP => 4 PLWSL",
          "114 ORE => 4 BHXH",
          "14 VRPVC => 6 BMBT",
          "6 BHXH, 18 KTJDG, 12 WPTQ, 7 PLWSL, 31 FHTLT, 37 ZDVW => 1 FUEL",
          "6 WPTQ, 2 BMBT, 8 ZLQW, 18 KTJDG, 1 XMNCP, 6 MZWV, 1 RJRHP => 6 FHTLT",
          "15 XDBXC, 2 LTCX, 1 VRPVC => 6 ZLQW",
          "13 WPTQ, 10 LTCX, 3 RJRHP, 14 XMNCP, 2 MZWV, 1 ZLQW => 1 ZDVW",
          "5 BMBT => 4 WPTQ",
          "189 ORE => 9 KTJDG",
          "1 MZWV, 17 XDBXC, 3 XCVML => 2 XMNCP",
          "12 VRPVC, 27 CNZTR => 2 XDBXC",
          "15 KTJDG, 12 BHXH => 5 XCVML",
          "3 BHXH, 2 VRPVC => 7 MZWV",
          "121 ORE => 7 VRPVC",
          "7 XCVML => 6 RJRHP",
          "5 BHXH, 4 VRPVC => 5 LTCX"
        ]
        |> Enum.map(&AoC.Day14.parse_line/1)

      reaction = AoC.Day14.find_reaction(all_reactions, "FUEL")

      stockpile = AoC.Day14.run_reaction([reaction], %{}, true, all_reactions)
      expect(Map.get(stockpile, "ORE")) |> to(eq(2_210_736))
    end

    xit do
      all_reactions =
        [
          "171 ORE => 8 CNZTR",
          "7 ZLQW, 3 BMBT, 9 XCVML, 26 XMNCP, 1 WPTQ, 2 MZWV, 1 RJRHP => 4 PLWSL",
          "114 ORE => 4 BHXH",
          "14 VRPVC => 6 BMBT",
          "6 BHXH, 18 KTJDG, 12 WPTQ, 7 PLWSL, 31 FHTLT, 37 ZDVW => 1 FUEL",
          "6 WPTQ, 2 BMBT, 8 ZLQW, 18 KTJDG, 1 XMNCP, 6 MZWV, 1 RJRHP => 6 FHTLT",
          "15 XDBXC, 2 LTCX, 1 VRPVC => 6 ZLQW",
          "13 WPTQ, 10 LTCX, 3 RJRHP, 14 XMNCP, 2 MZWV, 1 ZLQW => 1 ZDVW",
          "5 BMBT => 4 WPTQ",
          "189 ORE => 9 KTJDG",
          "1 MZWV, 17 XDBXC, 3 XCVML => 2 XMNCP",
          "12 VRPVC, 27 CNZTR => 2 XDBXC",
          "15 KTJDG, 12 BHXH => 5 XCVML",
          "3 BHXH, 2 VRPVC => 7 MZWV",
          "121 ORE => 7 VRPVC",
          "7 XCVML => 6 RJRHP",
          "5 BHXH, 4 VRPVC => 5 LTCX"
        ]
        |> Enum.map(&AoC.Day14.parse_line/1)

      reaction = AoC.Day14.find_reaction(all_reactions, "FUEL")

      stockpile =
        AoC.Day14.run_to_exhaustion(reaction, %{"ORE" => 1_000_000_000_000}, all_reactions)

      expect(Map.get(stockpile, "FUEL")) |> to(eq(460_663))
    end
  end

  example_group "find_reaction/2" do
    it do
      expect(AoC.Day14.find_reaction(all_reactions(), "FUEL"))
      |> to(eq({{1, "FUEL"}, [{7, "A"}, {1, "E"}]}))
    end
  end

  example_group "parse_component/1" do
    it(do: expect(AoC.Day14.parse_component("1 ORE")) |> to(eq({1, "ORE"})))
    it(do: expect(AoC.Day14.parse_component("10 A")) |> to(eq({10, "A"})))
  end

  example_group "parse_line/1" do
    it do
      line = "59 CQGW, 15 MSNG, 6 XGKRF, 10 LJRQ, 1 HRKGV, 15 RKVC => 1 FUEL"

      expect(AoC.Day14.parse_line(line))
      |> to(
        eq(
          {{1, "FUEL"},
           [{59, "CQGW"}, {15, "MSNG"}, {6, "XGKRF"}, {10, "LJRQ"}, {1, "HRKGV"}, {15, "RKVC"}]}
        )
      )
    end
  end

  example_group "run_reaction/3" do
    it(
      do:
        expect(AoC.Day14.run_reaction([{{10, "A"}, [{10, "ORE"}]}], %{}, true, all_reactions()))
        |> to(eq(%{"A" => 10, "ORE" => 10}))
    )

    it(
      do:
        expect(AoC.Day14.run_reaction([{{1, "B"}, [{1, "ORE"}]}], %{}, true, all_reactions()))
        |> to(eq(%{"B" => 1, "ORE" => 1}))
    )

    it(
      do:
        expect(
          AoC.Day14.run_reaction([{{1, "C"}, [{7, "A"}, {1, "B"}]}], %{}, true, all_reactions())
        )
        |> to(eq(%{"B" => 0, "ORE" => 11, "A" => 3, "C" => 1}))
    )

    it(
      do:
        expect(
          AoC.Day14.run_reaction(
            [{{1, "FUEL"}, [{7, "A"}, {1, "E"}]}],
            %{},
            true,
            all_reactions()
          )
        )
        |> to(eq(%{"B" => 0, "A" => 2, "C" => 0, "ORE" => 31, "D" => 0, "E" => 0, "FUEL" => 1}))
    )
  end

  def all_reactions do
    [
      "10 ORE => 10 A",
      "1 ORE => 1 B",
      "7 A, 1 B => 1 C",
      "7 A, 1 C => 1 D",
      "7 A, 1 D => 1 E",
      "7 A, 1 E => 1 FUEL"
    ]
    |> Enum.map(&AoC.Day14.parse_line/1)
  end
end
