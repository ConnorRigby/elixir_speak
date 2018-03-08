defmodule Speak.EspeakBackend do
  @moduledoc """
  Simple espeak port wrapper.
  """
  require Logger
  @behaviour Speak.Backend

  @impl Speak.Backend
  def open(opts) do
    exe = Keyword.get(opts, :executable, System.find_executable("espeak"))

    if exe do
      port_opts = [
        :binary,
        :exit_status,
        :stderr_to_stdout
      ]

      port = Port.open({:spawn_executable, exe}, port_opts)
      pid = spawn(__MODULE__, :handle_espeak, [port])
      {:ok, pid}
    else
      {:error, :no_exe}
    end
  end

  @impl Speak.Backend
  def close(backend) do
    send(backend, :close)
    :ok
  end

  @impl Speak.Backend
  def speak(backend, text) do
    send(backend, {:speak, text})
    :ok
  end

  def handle_espeak(port) do
    receive do
      {:speak, text} ->
        Port.command(port, text <> "\n")
        handle_espeak(port)

      info ->
        Logger.info("Unhandled info: #{inspect(info)}")
        handle_espeak(port)
    end
  end
end
