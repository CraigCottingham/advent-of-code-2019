defmodule AoC.Day14 do
  @moduledoc false

  def part_1 do
    all_reactions =
      "data/day14-input.txt"
      |> File.stream!()
      |> Enum.map(&String.trim/1)
      |> parse_input_data()

    stockpile = run_reaction([find_reaction(all_reactions, "FUEL")], %{}, all_reactions)
    Map.get(stockpile, "ORE")
  end

  def part_2 do
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

  def run_reaction([], stockpile, _), do: stockpile

  def run_reaction(
        [{{product_amount, product_chemical}, reactants} | rest] = stack,
        stockpile,
        all_reactions
      ) do
    # IO.puts("Running #{reaction_to_string(reaction)}")
    case Enum.find(reactants, fn reactant -> !sufficient_reactant?(reactant, stockpile) end) do
      nil ->
        # IO.puts("Everything we need is in #{inspect stockpile}")
        updated_stockpile =
          reactants
          |> Enum.reduce(stockpile, fn {amount, chemical}, s ->
            remove_from_stockpile(s, chemical, amount)
          end)
          |> add_to_stockpile(product_chemical, product_amount)

        run_reaction(rest, updated_stockpile, all_reactions)

      {_, needed_chemical} ->
        subreaction = find_reaction(all_reactions, needed_chemical)
        run_reaction([subreaction | stack], stockpile, all_reactions)
    end
  end

  defp add_to_stockpile(stockpile, chemical, amount),
    do: Map.update(stockpile, chemical, amount, fn old_amount -> old_amount + amount end)

  defp parse_input_data(lines), do: Enum.map(lines, &parse_line/1)

  defp remove_from_stockpile(stockpile, "ORE", amount),
    do: add_to_stockpile(stockpile, "ORE", amount)

  defp remove_from_stockpile(stockpile, chemical, amount),
    do: Map.update!(stockpile, chemical, fn old_amount -> old_amount - amount end)

  defp sufficient_reactant?({_, "ORE"}, _), do: true

  defp sufficient_reactant?({desired_amount, chemical}, stockpile),
    do: Map.get(stockpile, chemical, 0) >= desired_amount

  # defp reaction_to_string({{amount, chemical}, reactants}) do
  #   "#{amount} #{chemical} <- #{
  #     reactants
  #     |> Enum.map(fn {a, c} -> "#{a} #{c}" end)
  #     |> Enum.join(", ")
  #   }"
  # end
end
