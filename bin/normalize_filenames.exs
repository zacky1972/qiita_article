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
      true -> maybe_do_normalize(filename)
      false -> do_normalize(filename)
    end
  end

  defp do_normalize(nil, _title, filename), do: filename

  defp do_normalize(id, title, _filename) do
    created_at =
      Qiita.get_created_at(id)
      |> Timex.parse!("{ISO:Extended}")
      |> Timex.format!("%Y%m%d", :strftime)

    normalized_title = normalized_title(title)

    build_filename(created_at, normalized_title)
  end

  defp do_normalize(filename) do
    {id, title} = filename |> path() |> parse_file()
    do_normalize(id, title, filename)
  end

  defp maybe_do_normalize(title, title, _date, filename), do: filename

  defp maybe_do_normalize(normalized_title, _filename_title, date, _filename),
    do: build_filename(date, normalized_title)

  defp maybe_do_normalize(filename) do
    {_id, raw_title} = filename |> path() |> parse_file()
    normalized_title = normalized_title(raw_title)

    %{"date" => date, "title" => filename_title} =
      Regex.named_captures(~r/^(?<date>\d{8})-(?<title>.+)\.md$/, filename)

    maybe_do_normalize(normalized_title, filename_title, date, filename)
  end

  defp path(filename), do: Path.join(File.cwd!(), "public") |> Path.join(filename)

  defp parse_file(path) do
    {%{"id" => id, "title" => title}, _body} = YamlFrontMatter.parse_file!(path)
    {id, title}
  end

  defp normalized_title(title) do
    Zarex.sanitize(title)
    |> then(&Regex.replace(~r/\[/, &1, "【"))
    |> then(&Regex.replace(~r/\]/, &1, "】"))
    |> String.slice(0, 80)
  end

  defp build_filename(created_at, normalized_title), do: "#{created_at}-#{normalized_title}.md"
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
