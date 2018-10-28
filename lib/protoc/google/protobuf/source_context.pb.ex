defmodule Google.Protobuf.SourceContext do
  @moduledoc false
  alias Pbuf.{Decoder, Encoder}
  import Bitwise, only: [bsr: 2, band: 2]

  alias __MODULE__

  defstruct [
    __pbuf__: true,
    file_name: ""
  ]

  @type t :: %SourceContext{
    file_name: String.t
  }


  @spec new(Enum.t) :: t
  def new(data) do
    struct(__MODULE__, data)
  end

  @spec encode_to_iodata!(t | map) :: iodata
  def encode_to_iodata!(data) do
    alias Elixir.Pbuf.Encoder
    [
      Encoder.field(:string, data.file_name, <<10>>),
    ]
  end

  @spec encode!(t | map) :: binary
  def encode!(data) do
    :erlang.iolist_to_binary(encode_to_iodata!(data))
  end

  @spec decode!(binary) :: t
  def decode!(data) do
    case Pbuf.Decoder.decode(__MODULE__, data) do
      {:ok, decoded} -> decoded
      {:error, err} -> raise err
    end
  end

  @spec decode(binary) :: {:ok, t} | :error
  def decode(data) do
    Pbuf.Decoder.decode(__MODULE__, data)
  end

  @spec decode(binary, Keyword.t) :: {binary, Keywor.t} | {:error, Decoder.Error.t}
  
  def decode(acc, <<10, data::binary>>) do
    Decoder.field(:string, :file_name, acc, data)
  end


  # failed to decode, either this is an unknown tag (which we can skip), or
  # it's a wrong type (which is an error)
  def decode(acc, data) do
    {prefix, data} = Decoder.varint(data)
    tag = bsr(prefix, 3)
    type = band(prefix, 7)

    case tag in [1] do
      false -> {acc, Decoder.skip(type, data)}
      true ->
        err = %Decoder.Error{
          tag: tag,
          module: __MODULE__,
          message: "#{__MODULE__} tag #{tag} has an incorrect write type of #{type}"
        }
        {:error, err}
    end
  end


  def __finalize_decode__(args) do
    struct = Elixir.Enum.reduce(args, %__MODULE__{}, fn
            {k, v}, acc -> Map.put(acc, k, v)
    end)

    struct
  end
end
