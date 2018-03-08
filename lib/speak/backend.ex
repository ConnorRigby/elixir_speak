defmodule Speak.Backend do
  @moduledoc """
  Backend for speaking.
  """

  @typedoc "Options that get passed to a backend."
  @type backend_opts :: Keyword.t()

  @typedoc "Process Identifier for a backend"
  @type backend_id :: pid

  @doc "Open/Initialize a backend."
  @callback open(backend_opts) :: {:ok, backend_id} | {:error, term}

  @doc "Close a backend."
  @callback close(backend_id) :: :ok | {:error, term}

  @doc "Say some words."
  @callback speak(backend_id, binary) :: :ok | {:error, term}
end
