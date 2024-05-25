defmodule ApolloWeb.GeminiComponents do
  use Phoenix.Component

  alias Phoenix.LiveView.JS
  import Phoenix.HTML
  import ApolloWeb.Gettext

  attr :document, :map

  def gmi(assigns) do
    ~H"""
    <p :for={line <- @document.lines} class="py-1">
      <%#= inspect line %>
      <%= raw(line_to_html(line, @document)) %>
    </p>
    """
  end

  attr :location, :string
  slot :inner_block
  def back_button(assigns) do
    ~H"""
    <span :if={@location} phx-click="back" class="cursor-pointer"><%= render_slot(@inner_block) %> (<%= @location %>)</span>
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
    "<div class=\"#{font_size} py-2\">#{heading}</div>"
  end

  defp line_to_html({:anchor, :error, line}, gmi) do
    "<span>invalid link #{line}</span>"
  end

  defp line_to_html({:anchor, url, title}, gmi) do
    # target = %{uri | scheme: "gemini"}
    # query = URI.encode_query(%{uri: target})
    # {:ok, uri} = URI.new(%URI{path: "/", query: query})
    # URI.to_string(uri)
    case ApolloWeb.proxy_link(url, gmi) do
      {:gopher, apollo_url} -> "<a href=\"#{apollo_url}\">🚜 #{title}</a>"
      {:gemini, _apollo_url} -> "<span class=\"cursor-pointer\" phx-click=\"navigate\" phx-value-url=\"#{url}\">🚀 #{title}</span>"
      {_, url} -> "<a href=\"#{url}\" target=\"_blank\">🌐 #{title}</a>"
      :error -> "<span>ERROR</span>"
    end
  end

  defp line_to_html({:code, flag}, _gmi) do
    if flag, do: "<code>", else: "</code>"
  end

  defp line_to_html({:quote, line}, _gmi) do
    "<blockquote><tt>#{line}</tt></blockquote>"
  end

  defp line_to_html({:line, :empty}, _gmi), do: "<br>"
  defp line_to_html({:line, line}, _gmi), do: "<span>#{line}</span>"
end
