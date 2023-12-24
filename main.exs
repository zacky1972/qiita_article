defmodule Main do
  import Nx.Defn

  @s64_max Bitwise.bsl(1, 63) - 1

  def main() do
    n =
      IO.read(:line)
      |> String.trim()
      |> String.to_integer()

    a =
      0..333
      |> Stream.map(fn n -> repunit(n) end)
      |> Enum.take_while(& &1 <= @s64_max)

    t =
      a
      |> Enum.map(fn x ->
        a
        |> Enum.map(fn y ->
          a
          |> Enum.map(fn z ->
            x + y + z
          end)
        end)
      end)
      |> Nx.tensor(type: {:s, 64})

    1..n
    |> Enum.reduce(0, fn _, acc ->
      reduce_min_greater_than_n(t, acc, @s64_max)
    end)
    |> Nx.to_number()
    |> IO.puts()
  end

  def repunit(0), do: 1
  def repunit(n) when n > 0, do: 1 + 10 * repunit(n - 1)

  defn reduce_min_greater_than_n(t1, t2, t3) do
    t3 = Nx.multiply(Nx.less_equal(t1, t2), t3)
    t1 = Nx.multiply(Nx.greater(t1, t2), t1)
    Nx.add(t1, t3) |> Nx.reduce_min()
  end
end
