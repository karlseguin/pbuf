defmodule Google.Protobuf.Struct do
  @moduledoc false
  alias Pbuf.Decoder
  import Bitwise, only: [bsr: 2, band: 2]

  @derive Jason.Encoder
  defstruct [
    fields: %{}
  ]
  @type t :: %__MODULE__{
    fields: %{optional(String.t) => any}
  }

  @spec new(Enum.t) :: t
  def new(data) do
    struct(__MODULE__, data)
  end
  @spec encode_to_iodata!(t | map) :: iodata
  def encode_to_iodata!(data) do
    alias Elixir.Pbuf.Encoder
    [
      Encoder.map_field(<<10>>, :string, <<18>>, :struct, data.fields, <<10>>),
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
    post_map(:fields, 1, Decoder.map_field(10, :string, "", 18, Google.Protobuf.Value, nil, :fields, acc, data))
  end

  # failed to decode, either this is an unknown tag (which we can skip), or
  # it is a wrong type (which is an error)
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
          message: "#{__MODULE__} tag #{tag} has an incorrect type of #{type}"
        }
        {:error, err}
    end
  end
  defp post_map(name, tag, {:error, %{tag: nil, message: message}}) do
    err = %Decoder.Error{
      tag: tag,
      module: __MODULE__,
      message: "#{__MODULE__}.#{name} tag #{tag} " <> message
    }
    {:error, err}
  end
  # either valid data or a complete error (which would happen if our value
  # was a struct and the error happened decoding it)
  defp post_map(_name, _prefix, data) do
    data
  end
  def __finalize_decode__(args) do
    struct = Elixir.Enum.reduce(args, %__MODULE__{}, fn
      {:fields, {c, v}}, acc -> Map.update(acc, :fields, %{c => v}, fn m -> Map.put(m, c, v) end)
                  {k, v}, acc -> Map.put(acc, k, v)
    end)
    struct
  end
end
defmodule Google.Protobuf.Value do
  @moduledoc false
  alias Pbuf.Decoder
  import Bitwise, only: [bsr: 2, band: 2]

  @derive Jason.Encoder
  defstruct [
    kind: nil
  ]
  @type t :: %__MODULE__{
    kind: map | {:null_value, Google.Protobuf.NullValue.t} | {:number_value, number} | {:string_value, String.t} | {:bool_value, boolean} | {:struct_value, Google.Protobuf.Struct.t} | {:list_value, Google.Protobuf.ListValue.t}
  }

  @spec new(Enum.t) :: t
  def new(data) do
    struct(__MODULE__, data)
  end
  @spec encode_to_iodata!(t | map) :: iodata
  def encode_to_iodata!(data) do
    alias Elixir.Pbuf.Encoder
    [
      Encoder.oneof_field(:null_value, data.kind, fn v -> Encoder.enum_field(Google.Protobuf.NullValue, v, <<8>>) end),
      Encoder.oneof_field(:number_value, data.kind, fn v -> Encoder.field(:double, v, <<17>>) end),
      Encoder.oneof_field(:string_value, data.kind, fn v -> Encoder.field(:string, v, <<26>>) end),
      Encoder.oneof_field(:bool_value, data.kind, fn v -> Encoder.field(:bool, v, <<32>>) end),
      Encoder.oneof_field(:struct_value, data.kind, fn v -> Encoder.field(:struct, v, <<42>>) end),
      Encoder.oneof_field(:list_value, data.kind, fn v -> Encoder.field(:struct, v, <<50>>) end),
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
    Decoder.oneof_field(:kind, 0, Decoder.enum_field(Google.Protobuf.NullValue, :null_value, acc, data), nil)
  end
  
  def decode(acc, <<17, data::binary>>) do
    Decoder.oneof_field(:kind, 0, Decoder.field(:double, :number_value, acc, data), nil)
  end
  
  def decode(acc, <<26, data::binary>>) do
    Decoder.oneof_field(:kind, 0, Decoder.field(:string, :string_value, acc, data), nil)
  end
  
  def decode(acc, <<32, data::binary>>) do
    Decoder.oneof_field(:kind, 0, Decoder.field(:bool, :bool_value, acc, data), nil)
  end
  
  def decode(acc, <<42, data::binary>>) do
    Decoder.oneof_field(:kind, 0, Decoder.struct_field(Google.Protobuf.Struct, :struct_value, acc, data), nil)
  end
  
  def decode(acc, <<50, data::binary>>) do
    Decoder.oneof_field(:kind, 0, Decoder.struct_field(Google.Protobuf.ListValue, :list_value, acc, data), nil)
  end

  # failed to decode, either this is an unknown tag (which we can skip), or
  # it is a wrong type (which is an error)
  def decode(acc, data) do
    {prefix, data} = Decoder.varint(data)
    tag = bsr(prefix, 3)
    type = band(prefix, 7)
    case tag in [1,2,3,4,5,6] do
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
defmodule Google.Protobuf.ListValue do
  @moduledoc false
  alias Pbuf.Decoder
  import Bitwise, only: [bsr: 2, band: 2]

  @derive Jason.Encoder
  defstruct [
    values: []
  ]
  @type t :: %__MODULE__{
    values: [Google.Protobuf.Value.t]
  }

  @spec new(Enum.t) :: t
  def new(data) do
    struct(__MODULE__, data)
  end
  @spec encode_to_iodata!(t | map) :: iodata
  def encode_to_iodata!(data) do
    alias Elixir.Pbuf.Encoder
    [
      Encoder.repeated_field(:struct, data.values, <<10>>),
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
    Decoder.struct_field(Google.Protobuf.Value, :values, acc, data)
  end

  # failed to decode, either this is an unknown tag (which we can skip), or
  # it is a wrong type (which is an error)
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
          message: "#{__MODULE__} tag #{tag} has an incorrect type of #{type}"
        }
        {:error, err}
    end
  end

  def __finalize_decode__(args) do
    struct = Elixir.Enum.reduce(args, %__MODULE__{}, fn
      
      {:values, v}, acc -> Map.update(acc, :values, [v], fn e -> [v | e] end)
            {k, v}, acc -> Map.put(acc, k, v)
    end)
    struct = Map.put(struct, :values, Elixir.Enum.reverse(struct.values))
    struct
  end
end
defmodule Google.Protobuf.NullValue do
  @moduledoc false
  @type t :: :NULL_VALUE | 0
  @spec to_int(t | non_neg_integer) :: integer
  def to_int(:NULL_VALUE), do: 0
  def to_int(0), do: 0
  def to_int(invalid) do
    raise Pbuf.Encoder.Error,
      type: __MODULE__,
      value: invalid,
      tag: nil,
      message: "#{inspect(invalid)} is not a valid enum value for #{__MODULE__}"
  end
  @spec from_int(integer) :: t
  def from_int(0), do: :NULL_VALUE
  def from_int(_unknown), do: :invalid
end
