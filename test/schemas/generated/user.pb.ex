defmodule Pbuf.Tests.Sub.User do
  @moduledoc false
  alias Pbuf.{Decoder, Encoder}
  import Bitwise, only: [bsr: 2, band: 2]

  alias __MODULE__

  defstruct [
    __pbuf__: true,
    id: 0,
    status: 0
  ]

  @type t :: %User{
    id: non_neg_integer,
    status: Pbuf.Tests.Sub.UserStatus.t
  }


  @spec new(Enum.t) :: t
  def new(data) do
    struct(__MODULE__, data)
  end

  @spec encode_to_iodata!(t | map) :: iodata
  def encode_to_iodata!(data) do
    alias Elixir.Pbuf.Encoder
    [
      Encoder.field(:uint32, data.id, <<8>>),
      Encoder.enum_field(Pbuf.Tests.Sub.UserStatus, data.status, <<16>>),
    ]
  end

  @spec encode!(t | map) :: binary
  def encode!(data) do
    :erlang.iolist_to_binary(encode_to_iodata!(data))
  end

  @spec decode(binary) :: {:ok, t} | :error
  def decode(data) do
    Pbuf.Decoder.decode(__MODULE__, data)
  end

  @spec decode(binary, Keyword.t) :: {binary, Keywor.t} | {:error, Decoder.Error.t}
  
  def decode(acc, <<8, data::binary>>) do
    Decoder.field(:uint32, :id, acc, data)
  end
  
  def decode(acc, <<16, data::binary>>) do
    Decoder.enum_field(Pbuf.Tests.Sub.UserStatus, :status, acc, data)
  end


  # failed to decode, either this is an unknown tag (which we can skip), or
  # it's a wrong type (which is an error)
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
          message: "#{__MODULE__} tag #{tag} has an incorrect write type of #{type}"
        }
        {:error, err}
    end
  end


  def __finalize_decode__(args) do
    struct = Enum.reduce(args, %__MODULE__{}, fn
            {k, v}, acc -> Map.put(acc, k, v)
    end)

    struct
  end
end
defmodule Pbuf.Tests.Sub.UserStatus do
  @moduledoc false
  @type t :: :USER_STATUS_DELETED | :USER_STATUS_NORMAL | :USER_STATUS_UNKNOWN | non_neg_integer
  @spec to_int(t | non_neg_integer) :: integer
  def to_int(:USER_STATUS_DELETED), do: 2
  def to_int(2), do: 2
  def to_int(:USER_STATUS_NORMAL), do: 1
  def to_int(1), do: 1
  def to_int(:USER_STATUS_UNKNOWN), do: 0
  def to_int(0), do: 0
  def to_int(invalid) do
    raise Pbuf.Encoder.Error,
      type: __MODULE__,
      value: invalid,
      tag: nil,
      message: "#{inspect(invalid)} is not a valid enum value for #{__MODULE__}"
  end

  @spec from_int(integer) :: t
  def from_int(2), do: :USER_STATUS_DELETED
  def from_int(1), do: :USER_STATUS_NORMAL
  def from_int(0), do: :USER_STATUS_UNKNOWN
  def from_int(_unknown), do: :invalid
end
