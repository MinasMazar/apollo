defmodule Apollo.Gemini.Gmi do
  defstruct [lines: []]

  def parse(chunks, context) when is_list(chunks) do
    {gmi, context} = for line <- chunks, reduce: {struct(__MODULE__), context} do
      {gmi, context} ->
	{line, context} = parse(line, context)
	{Map.update(gmi, :lines, [], fn lines -> lines ++ [line] end), context}
    end

    gmi
  end

  def parse(line, context) when is_binary(line) do
    line = case String.slice(line, 0, 3) do
	     "#" <> _ -> heading_to_html(line)
	     "=> " -> anchor_to_html(line, context)
	     "```" -> toggle_code_block(context)
	     ">" <> _ -> quote_to_html(line)
	     "" -> {:line, :empty}
	     _ -> {:line, line}
	   end
    {line, context}
  end

  defp heading_to_html(line) do
    with [_, sharps, heading] <- Regex.run(~r[(#+)\s(.+)], line) do
      head_level = Enum.min([1, Enum.max([String.length(sharps), 6])])
      font_size = case head_level do
	h when h >= 1 and h <= 3 -> "text-2xl"
	h when h > 3 -> "text-xl"
      end
      {:heading, head_level, heading}
    else
      _ -> :error
    end
  end

  defp anchor_to_html(line, context) do
    with [_, url, title] <- Regex.run(~r[=>\s(.+?)\s(.+)], line),
	 {:ok, uri} <- URI.new(url) do
      uri =  uri
      |> Map.update(:scheme, nil, fn scheme -> scheme || context.uri.scheme end)
      |> Map.update(:host, nil, fn host -> host || context.uri.host end)
      {:anchor, uri, title}
    else
      _ -> :error
    end
  end

  defp quote_to_html(line) do
    with [_, block] <- Regex.run(~r[>\s(.+)], line) do
      {:quote, block}
    end
  end

  defp toggle_code_block(context) do
    context = context
    |> Map.put_new(:codeblock, false)

    {:code, !context.codeblock}
  end
end
