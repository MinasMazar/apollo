defmodule Apollo.Gemini.Gmi do
  defstruct [uri: nil, lines: [], error: nil]

  def parse(chunks, context) when is_list(chunks) do
    {lines, context} = for line <- chunks, reduce: {[], context} do
      {lines, context} ->
	{line, context} = parse(line, context)
	{lines ++ [line], context}
    end

    lines
  end
require Logger
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
      _ -> {:error, line}
    end
  end

  defp anchor_to_html(line, context) do
    result = with [_, url, title] <- Regex.run(~r[^=>\s(.+?)\s(.+)], line) do
	       {url, title}
	     else
	       _ -> :error
	     end
    with {url, title} <- result,
	 {:ok, uri} <- URI.new(url) do
      {:anchor, uri, title}
    else
      _ -> {:anchor, :error, line}
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
