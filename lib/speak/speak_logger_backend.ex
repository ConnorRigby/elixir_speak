defmodule Speak.LoggerBackend do
  @moduledoc """
  Backend for Speaking logs.

  ## Example:
  iex()> Logger.add_backend(SpeakLoggerBackend)
  iex()> require Logger
  iex()> Logger.debug("hey!")
  iex()> # List to the nice speaking.
  """

  @behaviour :gen_event

  def init(_args) do
    config = Application.get_env(:speak, :speak_logger_backend, [])
    speak_backend = Keyword.get(config, :speak_backend, Speak.EspeakBackend)
    speak_backend_opts = Keyword.get(config, :speak_backend_opts, [])

    {:ok, speak_server} =
      Speak.Server.start_link(backend: speak_backend, backend_opts: speak_backend_opts)

    Process.link(speak_server)
    {:ok, %{speak_server: speak_server}}
  end

  def handle_call({:configure, _options}, state) do
    # TODO(Connor): Allow reconfiguration.
    {:ok, :ok, state}
  end

  def handle_event({_level, gl, _event}, state) when node(gl) != node() do
    {:ok, state}
  end

  def handle_event({_level, _gl, {Logger, msg, _ts, _md}}, state) do
    try do
      text = to_string(msg)
      if String.printable?(text) do
        Speak.Server.speak(state.speak_server, text)
      end
      :ok
    rescue
      _ -> :ok
    end

    {:ok, state}
  end

  def handle_event(:flush, state), do: {:ok, state}
  def handle_info(_, state), do: {:ok, state}
end
