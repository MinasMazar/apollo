defmodule Apollo.Gemini do
  @moduledoc """
  The Gemini context.
  """

  import Ecto.Query, warn: false
  alias Apollo.Repo

  alias Apollo.Gemini.{Api, Visit}

  @doc """
  Returns the list of visits.

  ## Examples

      iex> list_visits()
      [%Visit{}, ...]

  """
  def list_visits do
    Repo.all(Visit)
  end

  @doc """
  Gets a single visit.

  Raises `Ecto.NoResultsError` if the Visit does not exist.

  ## Examples

      iex> get_visit!(123)
      %Visit{}

      iex> get_visit!(456)
      ** (Ecto.NoResultsError)

  """
  def get_visit!(id) do
    Repo.get!(Visit, id)
  end

  @doc """
  Creates a visit.

  ## Examples

      iex> create_visit(%{field: value})
      {:ok, %Visit{}}

      iex> create_visit(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_visit(attrs \\ %{}) do
    %Visit{}
    |> Visit.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a visit.

  ## Examples

      iex> update_visit(visit, %{field: new_value})
      {:ok, %Visit{}}

      iex> update_visit(visit, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_visit(%Visit{} = visit, attrs) do
    visit
    |> Visit.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a visit.

  ## Examples

      iex> delete_visit(visit)
      {:ok, %Visit{}}

      iex> delete_visit(visit)
      {:error, %Ecto.Changeset{}}

  """
  def delete_visit(%Visit{} = visit) do
    Repo.delete(visit)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking visit changes.

  ## Examples

      iex> change_visit(visit)
      %Ecto.Changeset{data: %Visit{}}

  """
  def change_visit(%Visit{} = visit, attrs \\ %{}) do
    Visit.changeset(visit, attrs)
  end

  def to_gmi(url) when is_binary(url) do
    with {:ok, uri} <- URI.new(url),
	 gmi <- %Apollo.Gemini.Gmi{uri: uri} do
      case body(url) do
	{:ok, body} -> %{gmi | lines: Apollo.Gemini.Gmi.parse(body, %{uri: uri})}
	:not_found -> %{gmi | error: :not_found}
	{:error, error} -> %{gmi | error: "#{inspect error}"}
      end
    end
  end

  def body(url) do
    with :not_found <- body(url, :from_cache) do
      body(url, :from_api)
    else
      {:ok, body} -> {:ok, body}
    end
  end

  def body(url, :from_api) do
    case Api.request(url, []) do
      {:ok, %{response: %{status: :not_found}}} -> :not_found
      {:ok, %{response: %{status: :success, body: body}}} ->
	with body <- normalize_body(body) do
	  Apollo.Gemini.Cache.set(url, body)
	  {:ok, body}
	end
      {:ok, %{response: %{status: _}}} -> {:error, :unknown_status}
      other -> {:error, other}
    end
  end

  def body(url, :from_cache) do
    if body = Apollo.Gemini.Cache.get(url) do
      {:ok, body}
    else
      :not_found
    end
  end

  defp normalize_body(body) do
    case body do
      content when is_binary(content) -> String.split(content, ~r([\n|\r]))
      [content] when is_binary(content) -> String.split(content, ~r([\n|\r]))
      chunks when is_list(chunks) ->
	chunks
	|> Enum.map(fn line -> String.split(line, ~r([\n|\r])) end)
	|> List.flatten()
    end
  end
end
