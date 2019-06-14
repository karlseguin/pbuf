defmodule Google.Protobuf.Any do
  @moduledoc false
  alias Pbuf.Decoder
  import Bitwise, only: [bsr: 2, band: 2]

  @derive Jason.Encoder
  defstruct [
    type_url: "",
    value: <<>>
  ]
  @type t :: %__MODULE__{
    type_url: String.t,
    value: binary
  }

  @spec new(Enum.t) :: t
  def new(data) do
    struct(__MODULE__, data)
  end
  @spec encode_to_iodata!(t | map) :: iodata
  def encode_to_iodata!(data) do
    alias Elixir.Pbuf.Encoder
    [
      Encoder.field(:string, data.type_url, <<10>>),
      Encoder.field(:bytes, data.value, <<18>>),
    ]
  end
  @spec encode!(t | map) :: binary
  def encode!(data) do
    :erlang.iolist_to_binary(encode_to_iodata!(data))
  end
  @spec decode!(binary) :: t
  def decode!(data) do
    Decoder.decode!(__MODULE__, data)
  end
  @spec decode(binary) :: {:ok, t} | :error
  def decode(data) do
    Decoder.decode(__MODULE__, data)
  end
  
  def decode(acc, <<10, data::binary>>) do
    Decoder.field(:string, :type_url, acc, data)
  end
  
  def decode(acc, <<18, data::binary>>) do
    Decoder.field(:bytes, :value, acc, data)
  end

  # failed to decode, either this is an unknown tag (which we can skip), or
  # it is a wrong type (which is an error)
  def decode(acc, data) do
    {prefix, data} = Decoder.varint(data)
    tag = bsr(prefix, 3)
    type = band(prefix, 7)
    case tag in [1,2] do
      false -> {acc, Decoder.skip(type, data)}
      true ->
        err = %Decoder.Error{
          tag: tag,
          module: __MODULE__,
          message: "#{__MODULE__} tag #{tag} has an incorrect type of #{type}"
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
