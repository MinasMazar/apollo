defmodule ApolloWeb.GeminiComponents do
  use Phoenix.Component
  import Phoenix.HTML

  attr :document, :map
  def gmi(assigns) do
    ~H"""
    <p :for={line <- @document.lines}>
      <%#= inspect line %>
      <%= line_to_html(line, @document) %>
    </p>
    """
  end

  defp line_to_html({:heading, level, heading}, _gmi) do
    font_size = case level do
		  1 -> "text-3xl"
		  2 -> "text-2xl"
		  3 -> "text-2xl"
		  4 -> "text-2xl"
		  5 -> "text-xl"
		  _ -> "text-xl text-red-500"
		end
    assigns = %{heading: heading, font_size: font_size}
    ~H"""
    <div class={"#{@font_size} py-2"}><%= @heading %></div>
    """
  end

  defp line_to_html({:anchor, :error, line}, _gmi) do
    assigns = %{line: line}
    ~H"""
    <span>invalid link <%= @line %></span>
    """
  end

  defp line_to_html({:anchor, url, title}, gmi) do
    case ApolloWeb.proxy_link(url, gmi) do
      {:http, url} -> http_link(url: url, title: title)
      {:gemini, apollo_url, gemini_url} -> gemini_link(apollo_url: apollo_url, gemini_url: gemini_url, title: title)
      {_other, url} -> other_link(url: url, title: title)
      :error -> "<span class=\"py-0.5\">ERROR</span>"
    end
  end

  defp line_to_html({:code_boundary, flag}, _gmi) do
    if flag, do: raw("<code class=\"py-2\">"), else: raw("</code>")
  end

  defp line_to_html({:code, line}, _gmi) do
    assigns = %{line: line}
    ~H"""
    <p class="-my-1.5"><%= @line %></p>
    """
  end

  defp line_to_html({:quote, line}, _gmi) do
    raw("<blockquote class=\"py-2\"><tt>#{line}</tt></blockquote>")
  end

  defp line_to_html({:line, :empty}, _gmi), do: raw("<br>")
  defp line_to_html({:line, line}, _gmi), do: raw("<p class=\"py-0.5\">#{line}</p>")

  defp gemini_link(assigns) do
    assigns = Enum.into(assigns, %{})
    ~H"""
    <span class="hover:bg-cyan-400">
      => 
      <.link phx-click="navigate" phx-value-url={@gemini_url} class="py-0.5 cursor-pointer underline"><%= @title %></.link>
    </span>
    """
  end

  defp http_link(assigns) do
    assigns = Enum.into(assigns, %{})
    ~H"""
    <span class="hover:bg-rose-400">
      ->
      <a class="py-0.5" href={@url} target="_blank"><%= @title %></a>
    </span>
    """
  end

  defp other_link(assigns) do
    assigns = Enum.into(assigns, %{})
    ~H"""
    <a class="py-0.5" href={@url} target="_blank"><%= @title %></a>
    """
  end
end
