defmodule Main do
  import Nx.Defn

  @u64_max Bitwise.bsl(1, 64) - 1

  def main() do
    n =
      IO.read(:line)
      |> String.trim()
      |> String.to_integer()

    a =
      1..333
      |> Enum.map(fn n -> repunit(n) end)
      |> Enum.filter(& &1 <= @u64_max)
      |> Nx.tensor(type: {:u, 64})

    s = Nx.shape(a) |> elem(0)

  end

  def repunit(0), do: 1
  def repunit(n) when n > 0, do: 1 + 10 * repunit(n - 1)
end
