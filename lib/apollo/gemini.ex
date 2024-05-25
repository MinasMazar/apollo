defmodule Apollo.Gemini do
  @moduledoc """
  The Gemini context.
  """

  import Ecto.Query, warn: false
  alias Apollo.Repo

  alias Apollo.Gemini.{Api, Bookmark}

  @doc """
  Returns the list of bookmarks.

  ## Examples

      iex> list_bookmarks()
      [%Bookmark{}, ...]

  """
  def list_bookmarks do
    Repo.all(Bookmark)
  end

  @doc """
  Gets a single bookmark.

  Raises `Ecto.NoResultsError` if the Bookmark does not exist.

  ## Examples

      iex> get_bookmark!(123)
      %Bookmark{}

      iex> get_bookmark!(456)
      ** (Ecto.NoResultsError)

  """
  def get_bookmark!(id) do
    Repo.get!(Bookmark, id)
  end

  @doc """
  Creates a bookmark.

  ## Examples

      iex> create_bookmark(%{field: value})
      {:ok, %Bookmark{}}

      iex> create_bookmark(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_bookmark(attrs \\ %{}) do
    %Bookmark{}
    |> Bookmark.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a bookmark.

  ## Examples

      iex> update_bookmark(bookmark, %{field: new_value})
      {:ok, %Bookmark{}}

      iex> update_bookmark(bookmark, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_bookmark(%Bookmark{} = bookmark, attrs) do
    bookmark
    |> Bookmark.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a bookmark.

  ## Examples

      iex> delete_bookmark(bookmark)
      {:ok, %Bookmark{}}

      iex> delete_bookmark(bookmark)
      {:error, %Ecto.Changeset{}}

  """
  def delete_bookmark(%Bookmark{} = bookmark) do
    Repo.delete(bookmark)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking bookmark changes.

  ## Examples

      iex> change_bookmark(bookmark)
      %Ecto.Changeset{data: %Bookmark{}}

  """
  def change_bookmark(%Bookmark{} = bookmark, attrs \\ %{}) do
    Bookmark.changeset(bookmark, attrs)
  end

  def to_gmi(url) when is_binary(url) do
    with {:ok, uri} <- URI.new(url),
	 gmi <- %Apollo.Gemini.Gmi{uri: uri} do
      case body(url) do
	{:success, body} -> %{gmi | lines: Apollo.Gemini.Gmi.parse(body, %{uri: uri})}
	:not_found -> %{gmi | error: :not_found}
	:redirected -> %{gmi | error: :redirected}
	{:error, error} -> %{gmi | error: "#{inspect error}"}
      end
    end
  end

  def body(url) do
    with :not_found <- body(url, :from_cache) do
      body(url, :from_api)
    else
      {:ok, body} -> {:success, body}
    end
  end

  def body(url, :from_api) do
    case Api.request(url, []) do
      {:ok, %{response: %{status: :not_found}}} -> :not_found
      {:ok, %{response: %{status: :success, body: body}}} ->
	with body <- normalize_body(body) do
	  Apollo.Gemini.Cache.set(url, body)
	  {:success, body}
	end
      {:ok, %{response: response = %{status: status}}} ->
	if Api.Status.redirect?(response) do
	  :redirected
	else
	  {:error, inspect(status)}
	end
      other -> {:error, inspect(other)}
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
