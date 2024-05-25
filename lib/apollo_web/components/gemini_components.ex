defmodule ApolloWeb.GeminiComponents do
  use Phoenix.Component

  alias Phoenix.LiveView.JS
  import Phoenix.HTML
  import ApolloWeb.Gettext

  attr :lines, :list

  def gmi(assigns) do
    ~H"""
    <p :for={line <- @lines} class="py-1">
      <%#= inspect line %>
      <%= raw(line_to_html(line)) %>
    </p>
    """
  end

  defp line_to_html({:heading, level, heading}) do
    font_size = case level do
		  1 -> "text-3xl"
		  2 -> "text-2xl"
		  3 -> "text-2xl"
		  4 -> "text-2xl"
		  5 -> "text-xl"
		  _ -> "text-xl text-red-500"
		end
    "<div class=\"#{font_size} py-2\">#{heading}</div>"
  end

  defp line_to_html({:anchor, url, title}) do
    case ApolloWeb.proxy_link(url) do
      {:gopher, url} -> "<a href=\"#{url}\">🚜 #{title}</a>"
      {:gemini, url} -> "<a href=\"#{url}\">🚀 #{title}</a>"
      {:http, url} -> "<a href=\"#{url}\" target=\"_blank\">🌐 #{title}</a>"
      :error -> "<span>UNABLE TO PARSE LINK</span>"
    end
  end

  defp line_to_html({:code, flag}) do
    if flag, do: "<code>", else: "</code>"
  end

  defp line_to_html({:quote, line}) do
    "<blockquote><tt>#{line}</tt></blockquote>"
  end

  defp line_to_html({:line, :empty}), do: "<br>"
  defp line_to_html({:line, line}), do: "<span>#{line}</span>"
end
