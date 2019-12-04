ESpec.configure(fn config ->
  config.before(fn tags ->
    {:shared, solutions: AoC.SpecHelper.load_solutions(), tags: tags}
  end)

  config.finally(fn _shared ->
    :ok
  end)
end)

defmodule AoC.SpecHelper do
  @moduledoc false

  def load_solutions do
    "solutions.json"
    |> File.read!()
    |> Jason.decode!()
  end
end
