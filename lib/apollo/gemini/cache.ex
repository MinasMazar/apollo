defmodule Apollo.Gemini.Cache do
  use GenServer

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  def init(_) do
    {:ok, %{}}
  end

  def free(pid \\ __MODULE__), do: :sys.replace_state(pid, fn _ -> %{} end)

  def get(pid \\ __MODULE__, key) do
    GenServer.call(pid, {:get, key})
  end

  def set(pid \\ __MODULE__, key, value) do
    GenServer.cast(pid, {:set, key, value})
  end

  def handle_call({:get, key}, _, cache) do
    value = Map.get(cache, key)
    {:reply, value, cache}
  end

  def handle_cast({:set, key, value}, cache) do
    {:noreply, Map.put(cache, key, value)}
  end
end
