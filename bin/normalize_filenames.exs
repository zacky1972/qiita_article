Mix.install([
  {:req, "~> 0.4"},
  {:timex, "~> 3.7"},
  {:yaml_front_matter, "~> 1.0"},
  {:zarex, "~> 1.0"}
])

defmodule Qiita do
  @token System.fetch_env!("QIITA_TOKEN")
  @headers [Authorization: "Bearer #{@token}", Accept: "Application/json; Charset=utf-8"]

  def get_item(item_id) do
    Req.get("https://qiita.com/api/v2/items/#{item_id}", headers: @headers)
  end

  def get_created_at(item_id) do
    {:ok, res} = get_item(item_id)
    Map.get(res, :body) |> Map.get("created_at")
  end
end

defmodule NormalizeFilename do
  def normalize(filename) do
    case Regex.match?(~r/^\d{8}-.+\.md$/, filename) do
      true -> filename
      false -> do_normalize(filename)
    end
  end

  defp do_normalize(nil, _title, filename), do: filename

  defp do_normalize(id, title, _filename) do
    created_at =
      Qiita.get_created_at(id)
      |> Timex.parse!("{ISO:Extended}")
      |> Timex.format!("%Y%m%d", :strftime)

    normalized_title =
      Zarex.sanitize(title)
      |> then(&Regex.replace(~r/\[/, &1, "【"))
      |> then(&Regex.replace(~r/\]/, &1, "】"))
      |> String.slice(0, 80)

    "#{created_at}-#{normalized_title}.md"
  end

  defp do_normalize(filename) do
    path = Path.join(File.cwd!(), "public") |> Path.join(filename)

    {%{"id" => id, "title" => title}, _body} = YamlFrontMatter.parse_file!(path)
    do_normalize(id, title, filename)
  end
end

defmodule Main do
  def main do
    File.ls!("public")
    |> Enum.reject(&File.dir?("public/#{&1}"))
    |> Enum.filter(&String.ends_with?(&1, ".md"))
    |> Enum.each(fn filename ->
      normalized = NormalizeFilename.normalize(filename)

      IO.puts(normalized)
      :ok = File.rename("public/#{filename}", "public/#{normalized}")
    end)
  end
end

Main.main()
