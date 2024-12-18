defmodule Apollo.Gemini.Gmi do
  defstruct [uri: nil, lines: [], error: nil]

  def parse(chunks, context) when is_list(chunks) do
    context = context
    |> Map.put(:codeblock, false)

    {lines, _context} = for line <- chunks, reduce: {[], context} do
      {lines, context} ->
	{line, context} = parse(line, context)
	{lines ++ [line], post_line_parse(context)}
    end

    lines
  end

  def parse(line, context) when is_binary(line) do
    case String.slice(line, 0, 3) do
      "#" <> _ -> line_to_html(:heading, line, context)
      "=> " -> line_to_html(:anchor, line, context)
      "```" -> line_to_html(:code, line, context)
      ">" <> _ -> line_to_html(:quote, line, context)
      "" -> line_to_html(:empty, line, context)
      _ -> line_to_html(:line, line, context)
    end
  end

  defp line_to_html(:heading, line, context = %{codeblock: false}) do
    with [_, sharps, heading] <- Regex.run(~r[(#+)\s?(.+)], line) do
      head_level = Enum.min([1, Enum.max([String.length(sharps), 6])])
      {{:heading, head_level, heading}, context}
    else
      _ -> {{:error, line}, context}
    end
  end

  defp line_to_html(:anchor, line, context = %{codeblock: false}) do
    result = with [_, url, title] <- Regex.run(~r[^=>\s(.+?)\s+(.+)], line) do
	       {url, title}
	     else
	       [_, url] -> {url, url}
	     _ -> :error
	     end
    with {url, title} <- result,
	 {:ok, uri} <- URI.new(url) do
      {{:anchor, uri, title}, context}
    else
      _ -> {{:anchor, :error, line}, context}
    end
  end

  defp line_to_html(:quote, line, context = %{codeblock: false}) do
    case Regex.run(~r[>\s(.+)], line) do
      nil -> {{:quote, ""}, context}
      [_, block] -> {{:quote, block}, context}
    end
  end

  defp line_to_html(:empty, _line, context= %{codeblock: false}) do
    {{:line, ""}, context}
  end

  defp line_to_html(:line, line, context= %{codeblock: false}) do
    {{:line, line}, context}
  end

  defp line_to_html(:code, _line, context = %{codeblock: flag}) do
    {{:code_boundary, !flag}, %{context | codeblock: !flag}}
  end

  defp line_to_html(_type, line, context = %{codeblock: true}) do
    {{:code, line}, context}
  end

  defp post_line_parse(context) do
    context
  end
end
