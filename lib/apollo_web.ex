defmodule ApolloWeb do
  @moduledoc """
  The entrypoint for defining your web interface, such
  as controllers, components, channels, and so on.

  This can be used in your application as:

      use ApolloWeb, :controller
      use ApolloWeb, :html

  The definitions below will be executed for every controller,
  component, etc, so keep them short and clean, focused
  on imports, uses and aliases.

  Do NOT define functions inside the quoted expressions
  below. Instead, define additional modules and import
  those modules here.
  """

  def static_paths, do: ~w(assets fonts images favicon.ico robots.txt)

  def router do
    quote do
      use Phoenix.Router, helpers: false

      # Import common connection and controller functions to use in pipelines
      import Plug.Conn
      import Phoenix.Controller
      import Phoenix.LiveView.Router
    end
  end

  def channel do
    quote do
      use Phoenix.Channel
    end
  end

  def controller do
    quote do
      use Phoenix.Controller,
        formats: [:html, :json],
        layouts: [html: ApolloWeb.Layouts]

      import Plug.Conn
      import ApolloWeb.Gettext

      unquote(verified_routes())
    end
  end

  def live_view do
    quote do
      use Phoenix.LiveView,
        layout: {ApolloWeb.Layouts, :app}

      unquote(html_helpers())
    end
  end

  def live_component do
    quote do
      use Phoenix.LiveComponent

      unquote(html_helpers())
    end
  end

  def html do
    quote do
      use Phoenix.Component

      # Import convenience functions from controllers
      import Phoenix.Controller,
        only: [get_csrf_token: 0, view_module: 1, view_template: 1]

      # Include general helpers for rendering HTML
      unquote(html_helpers())
    end
  end

  defp html_helpers do
    quote do
      # HTML escaping functionality
      import Phoenix.HTML
      # Core UI components and translation
      import ApolloWeb.CoreComponents
      import ApolloWeb.Helpers
      import ApolloWeb.GeminiComponents
      import ApolloWeb.Gettext

      # Shortcut for generating JS commands
      alias Phoenix.LiveView.JS

      # Routes generation with the ~p sigil
      unquote(verified_routes())
    end
  end

  def verified_routes do
    quote do
      use Phoenix.VerifiedRoutes,
        endpoint: ApolloWeb.Endpoint,
        router: ApolloWeb.Router,
        statics: ApolloWeb.static_paths()
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/live_view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end

  def proxy_link(nil, _document), do: :error
  def proxy_link(url, document) do
    proxy_uri = URI.parse(ApolloWeb.Endpoint.url())
    case sanitize_target(url, document) do
      {:ok, %{scheme: "http" <> _}} -> {:http, url}
      {:ok, gemini_uri = %{scheme: "gemini"}} ->
	query_string = URI.encode_query(url: URI.to_string(gemini_uri))
	apollo_url = URI.append_query(proxy_uri, query_string)
	{:gemini, URI.to_string(apollo_url), URI.to_string(gemini_uri)}
      {:ok, uri = %URI{}} -> {uri.scheme, URI.to_string(uri)}
      {:error, _} -> :error
    end
  end

  def sanitize_target(url, document) when is_binary(url) do
    with {:ok, uri} <- URI.new(url) do
      sanitize_target(uri, document)
    end
  end

  def sanitize_target(uri = %URI{}, document) do
    document.uri
    |> URI.merge(uri)
    |> URI.new()
  end
end
