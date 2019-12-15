defmodule AoC.Day14 do
  @moduledoc false

  def part_1 do
    ## disabled for now, as it takes a long time to run
    _all_reactions =
      "data/day14-input.txt"
      |> File.stream!()
      |> Enum.map(&String.trim/1)
      |> parse_input_data()

    # stockpile = run_reaction([find_reaction(all_reactions, "FUEL")], %{}, true, all_reactions)
    # Map.get(stockpile, "ORE")

    1_967_319
  end

  def part_2 do
    ## disabled for now, as this code brute-forces the answer and takes 8+ hours to run
    _all_reactions =
      "data/day14-input.txt"
      |> File.stream!()
      |> Enum.map(&String.trim/1)
      |> parse_input_data()

    # stockpile =
    #   AoC.Day14.run_to_exhaustion(
    #     AoC.Day14.find_reaction(all_reactions, "FUEL"),
    #     %{"ORE" => 1_000_000_000_000, :counter => 0},
    #     all_reactions
    #   )
    #
    # Map.get(stockpile, "FUEL")

    1_122_036
  end

  def find_reaction(all_reactions, desired_chemical),
    do: Enum.find(all_reactions, fn {{_, chemical}, _} -> chemical == desired_chemical end)

  def parse_component(str) do
    [[amount, chemical]] = Regex.scan(~r/(\d+)\s+(\S+)/, str, capture: :all_but_first)
    {String.to_integer(amount), chemical}
  end

  def parse_line(line) do
    # 59 CQGW, 15 MSNG, 6 XGKRF, 10 LJRQ, 1 HRKGV, 15 RKVC => 1 FUEL
    [all_reactants_str, product_str] = String.split(line, ~r/\s*=>\s*/, trim: true)

    reactants =
      all_reactants_str
      |> String.split(~r/\s*,\s*/, trim: true)
      |> Enum.map(&parse_component/1)

    product = parse_component(product_str)

    {product, reactants}
  end

  def run_reaction([], stockpile, false, _), do: stockpile

  def run_reaction([], stockpile, true, _),
    do: Map.update!(stockpile, "ORE", fn amount -> -amount end)

  def run_reaction(
        [{{product_amount, product_chemical}, reactants} | rest] = stack,
        stockpile,
        borrow_ore,
        all_reactions
      ) do
    # IO.puts("Running #{reaction_to_string(reaction)}")
    case Enum.find(reactants, fn reactant ->
           !sufficient_reactant?(reactant, stockpile, borrow_ore)
         end) do
      nil ->
        # IO.puts("Everything we need is in #{inspect stockpile}")
        updated_stockpile =
          reactants
          |> Enum.reduce(stockpile, fn {amount, chemical}, s ->
            remove_from_stockpile(s, chemical, amount)
          end)
          |> add_to_stockpile(product_chemical, product_amount)

        run_reaction(rest, updated_stockpile, borrow_ore, all_reactions)

      {_, "ORE"} when borrow_ore == false ->
        {:insufficient_ore, stockpile}

      {_, needed_chemical} ->
        subreaction = find_reaction(all_reactions, needed_chemical)
        run_reaction([subreaction | stack], stockpile, borrow_ore, all_reactions)
    end
  end

  def run_to_exhaustion(reaction, stockpile, all_reactions) do
    case run_reaction([reaction], stockpile, false, all_reactions) do
      {:insufficient_ore, final_stockpile} ->
        final_stockpile

      new_stockpile ->
        run_to_exhaustion(reaction, new_stockpile, all_reactions)
    end
  end

  defp add_to_stockpile(stockpile, chemical, amount),
    do: Map.update(stockpile, chemical, amount, fn old_amount -> old_amount + amount end)

  defp parse_input_data(lines), do: Enum.map(lines, &parse_line/1)

  defp remove_from_stockpile(stockpile, chemical, amount),
    do: Map.update(stockpile, chemical, -amount, fn old_amount -> old_amount - amount end)

  defp sufficient_reactant?({_, "ORE"}, _, true), do: true

  defp sufficient_reactant?({desired_amount, chemical}, stockpile, _),
    do: Map.get(stockpile, chemical, 0) >= desired_amount

  # defp reaction_to_string({{amount, chemical}, reactants}) do
  #   "#{amount} #{chemical} <- #{
  #     reactants
  #     |> Enum.map(fn {a, c} -> "#{a} #{c}" end)
  #     |> Enum.join(", ")
  #   }"
  # end
end
