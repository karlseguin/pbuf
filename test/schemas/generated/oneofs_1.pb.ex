defmodule OneOfOne do
  @moduledoc false
  alias Pbuf.Decoder
  import Bitwise, only: [bsr: 2, band: 2]

  @derive Jason.Encoder
  defstruct [
    choice: nil
  ]
  @type t :: %__MODULE__{
    choice: map | {:a, integer} | {:b, integer}
  }

  @spec new(Enum.t) :: t
  def new(data) do
    struct(__MODULE__, data)
  end
  @spec encode_to_iodata!(t | map) :: iodata
  def encode_to_iodata!(data) do
    alias Elixir.Pbuf.Encoder
    [
      Encoder.oneof_field(:a, data.choice, 1, fn v -> Encoder.field(:int32, v, <<8>>) end),
      Encoder.oneof_field(:b, data.choice, 1, fn v -> Encoder.field(:int32, v, <<16>>) end),
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
  
  def decode(acc, <<8, data::binary>>) do
    Decoder.oneof_field(:choice, 1, Decoder.field(:int32, :a, acc, data))
  end
  
  def decode(acc, <<16, data::binary>>) do
    Decoder.oneof_field(:choice, 1, Decoder.field(:int32, :b, acc, data))
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
                  
      {:b, {choice, v}}, acc -> Map.put(acc, choice, %{__type: :b, value: v})
      {:a, {choice, v}}, acc -> Map.put(acc, choice, %{__type: :a, value: v})
            {k, v}, acc -> Map.put(acc, k, v)
    end)
    struct
  end
end
