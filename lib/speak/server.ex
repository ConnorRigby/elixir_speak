defmodule Speak.Server do
  @moduledoc """
  Server implementation for Speaking.

  ## Example
  {:ok, speak} = Speak.Server.start_link(backend: Speak.EspeakBackend)
  :ok = Speak.say("Hello world!")
  """
  use GenServer

  @doc "Start a Speaking Server."
  def start_link(opts) do
    GenServer.start_link(__MODULE__, [opts])
  end

  @doc "Stop a server."
  def stop(pid) do
    GenServer.stop(pid, :normal)
  end

  @doc "Say some words."
  def speak(pid, text, timeout \\ 5000) when is_binary(text) do
    GenServer.call(pid, {:speak, text}, timeout)
  end

  defmodule State do
    @moduledoc false
    defstruct [:backend_module, :backend_pid]
  end

  def init([opts]) do
    backend = Keyword.fetch!(opts, :backend)
    backend_opts = Keyword.get(opts, :backend_opts, [])

    case backend.open(backend_opts) do
      {:ok, pid} when is_pid(pid) ->
        Process.link(pid)
        {:ok, %State{backend_module: backend, backend_pid: pid}}

      {:error, err} ->
        {:stop, err}
    end
  end

  def handle_call({:speak, text}, _, state) do
    state.backend_module.speak(state.backend_pid, text)
    {:reply, :ok, state}
  end

  def terminate(_reason, state) do
    if Process.alive?(state.backend_pid) do
      state.backend_module.close(state.backend_pid)
    end

    :ok
  end
end
