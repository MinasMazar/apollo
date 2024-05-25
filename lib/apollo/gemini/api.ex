defmodule Apollo.Gemini.Api do
  @moduledoc """
  Apollo keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  alias Apollo.Gemini.Api.Status
  require Logger

  def request(path, opts) do
    opts = Keyword.put_new(opts, :timeout, :timer.seconds(5))

    case URI.parse(path) do
      %{scheme: "gemini"} = path -> gemini_request(path, opts)
      %{scheme: scheme} -> {:error, :invalid_scheme, scheme}
    end
  end

  def gemini_request(uri, opts) do
    Logger.info("#{__MODULE__} fetch Gemini resource: #{uri}")
    ssl_opts = prepare_opts(opts)

    with {host, path, port} = handle_uri(uri, opts[:query]),
         :ok <- ensure_started(),
         {:ok, socket} <- :ssl.connect(host, port, ssl_opts),
         :ok <- :ssl.send(socket, path),
         {:ok, body} <- recv(socket, ""),
         response <- prepare_response(body) do
      {:ok, %{request: uri2str(uri, opts[:query]), response: response}}
    end
  end

  def recv(socket, body) do
    case :ssl.recv(socket, 0) do
      {:error, :closed} -> {:ok, body}
      {:ok, data} -> recv(socket, body <> data)
      error -> error
    end
  end

  def handle_uri(%{host: host, port: port} = uri, query) do
    path =
      uri
      |> uri2str(query)
      |> then(&(&1 <> "\r\n"))
      |> to_charlist

    host = to_charlist(host)
    port = port || 1965

    {host, path, port}
  end

  def prepare_response(raw) when is_binary(raw) do
    [head | chunks] = String.split(raw, "\r\n")
    [status | meta] = String.split(head, " ")
    status = Status.from_code(status)

    %{status: status, body: chunks, meta: Enum.join(meta, " ")}
  end

  def uri2str(uri, nil), do: URI.to_string(uri)

  def uri2str(uri, query) do
    %{uri | query: URI.encode(query)}
    |> URI.to_string()
  end

  def prepare_opts(opts) do
    [:binary, verify: :verify_none, active: false, send_timeout: opts[:timeout]] ++
      maybe_cert(opts[:certificate], opts[:key])
  end

  def maybe_cert(nil, _), do: [verify: :verify_none]
  def maybe_cert(cert, key), do: [cacertfile: cert, keyfile: key, verify: :verify_peer]

  def ensure_started do
    case Application.ensure_started(:ssl) do
      :ok -> :ok
      _ -> :ssl.start()
    end
  end
end
