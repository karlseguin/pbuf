defmodule Pbuf.Tests.Everything do
  @moduledoc false
  alias Pbuf.Decoder
  import Bitwise, only: [bsr: 2, band: 2]

  @derive Jason.Encoder
  defstruct [
    choice: nil,
    bool: false,
    int32: 0,
    int64: 0,
    uint32: 0,
    uint64: 0,
    sint32: 0,
    sint64: 0,
    fixed32: 0,
    fixed64: 0,
    sfixed32: 0,
    sfixed64: 0,
    float: 0.0,
    double: 0.0,
    string: "",
    bytes: <<>>,
    struct: nil,
    type: :EVERYTHING_TYPE_UNKNOWN,
    corpus: :universal,
    user: nil,
    user_status: :USER_STATUS_UNKNOWN,
    bools: [],
    int32s: [],
    int64s: [],
    uint32s: [],
    uint64s: [],
    sint32s: [],
    sint64s: [],
    fixed32s: [],
    sfixed32s: [],
    fixed64s: [],
    sfixed64s: [],
    floats: [],
    doubles: [],
    strings: [],
    bytess: [],
    structs: [],
    types: [],
    corpuss: [],
    map1: %{},
    map2: %{},
    map3: %{}
  ]
  @type t :: %__MODULE__{
    choice: map | {:choice_int32, integer} | {:choice_string, String.t},
    bool: boolean,
    int32: integer,
    int64: integer,
    uint32: non_neg_integer,
    uint64: non_neg_integer,
    sint32: integer,
    sint64: integer,
    fixed32: integer,
    fixed64: integer,
    sfixed32: integer,
    sfixed64: integer,
    float: number,
    double: number,
    string: String.t,
    bytes: binary,
    struct: Pbuf.Tests.Child.t,
    type: Pbuf.Tests.EverythingType.t,
    corpus: Pbuf.Tests.Everything.Corpus.t,
    user: Pbuf.Tests.Sub.User.t,
    user_status: Pbuf.Tests.Sub.UserStatus.t,
    bools: [boolean],
    int32s: [integer],
    int64s: [integer],
    uint32s: [non_neg_integer],
    uint64s: [non_neg_integer],
    sint32s: [integer],
    sint64s: [integer],
    fixed32s: [integer],
    sfixed32s: [integer],
    fixed64s: [integer],
    sfixed64s: [integer],
    floats: [number],
    doubles: [number],
    strings: [String.t],
    bytess: [binary],
    structs: [Pbuf.Tests.Child.t],
    types: [Pbuf.Tests.EverythingType.t],
    corpuss: [Pbuf.Tests.Everything.Corpus.t],
    map1: %{optional(String.t) => any},
    map2: %{optional(integer) => any},
    map3: %{optional(non_neg_integer) => any}
  }
defmodule Corpus do
  @moduledoc false
  @type t :: :universal | 0 | :web | 1 | :images | 2 | :local | 3 | :news | 4 | :products | 5 | :video | 6
  @spec to_int(t | non_neg_integer) :: integer
  def to_int(:images), do: 2
  def to_int(2), do: 2
  def to_int(:local), do: 3
  def to_int(3), do: 3
  def to_int(:news), do: 4
  def to_int(4), do: 4
  def to_int(:products), do: 5
  def to_int(5), do: 5
  def to_int(:universal), do: 0
  def to_int(0), do: 0
  def to_int(:video), do: 6
  def to_int(6), do: 6
  def to_int(:web), do: 1
  def to_int(1), do: 1
  def to_int(invalid) do
    raise Pbuf.Encoder.Error,
      type: __MODULE__,
      value: invalid,
      tag: nil,
      message: "#{inspect(invalid)} is not a valid enum value for #{__MODULE__}"
  end
  @spec from_int(integer) :: t
  def from_int(2), do: :images
  def from_int(3), do: :local
  def from_int(4), do: :news
  def from_int(5), do: :products
  def from_int(0), do: :universal
  def from_int(6), do: :video
  def from_int(1), do: :web
  def from_int(_unknown), do: :invalid
end
defmodule EverythingType do
  @moduledoc false
  @type t :: :EVERYTHING_TYPE_UNKNOWN | 0 | :EVERYTHING_TYPE_SAND | 1 | :EVERYTHING_TYPE_SPICE | 2
  @spec to_int(t | non_neg_integer) :: integer
  def to_int(:EVERYTHING_TYPE_SAND), do: 1
  def to_int(1), do: 1
  def to_int(:EVERYTHING_TYPE_SPICE), do: 2
  def to_int(2), do: 2
  def to_int(:EVERYTHING_TYPE_UNKNOWN), do: 0
  def to_int(0), do: 0
  def to_int(invalid) do
    raise Pbuf.Encoder.Error,
      type: __MODULE__,
      value: invalid,
      tag: nil,
      message: "#{inspect(invalid)} is not a valid enum value for #{__MODULE__}"
  end
  @spec from_int(integer) :: t
  def from_int(1), do: :EVERYTHING_TYPE_SAND
  def from_int(2), do: :EVERYTHING_TYPE_SPICE
  def from_int(0), do: :EVERYTHING_TYPE_UNKNOWN
  def from_int(_unknown), do: :invalid
end
  @spec new(Enum.t) :: t
  def new(data) do
    struct(__MODULE__, data)
  end
  @spec encode_to_iodata!(t | map) :: iodata
  def encode_to_iodata!(data) do
    alias Elixir.Pbuf.Encoder
    [
      Encoder.field(:bool, data.bool, <<8>>),
      Encoder.field(:int32, data.int32, <<16>>),
      Encoder.field(:int64, data.int64, <<24>>),
      Encoder.field(:uint32, data.uint32, <<32>>),
      Encoder.field(:uint64, data.uint64, <<40>>),
      Encoder.field(:sint32, data.sint32, <<48>>),
      Encoder.field(:sint64, data.sint64, <<56>>),
      Encoder.field(:fixed32, data.fixed32, <<69>>),
      Encoder.field(:fixed64, data.fixed64, <<73>>),
      Encoder.field(:sfixed32, data.sfixed32, <<85>>),
      Encoder.field(:sfixed64, data.sfixed64, <<89>>),
      Encoder.field(:float, data.float, <<101>>),
      Encoder.field(:double, data.double, <<105>>),
      Encoder.field(:string, data.string, <<114>>),
      Encoder.field(:bytes, data.bytes, <<122>>),
      Encoder.field(:struct, data.struct, <<130, 1>>),
      Encoder.enum_field(Pbuf.Tests.EverythingType, data.type, <<136, 1>>),
      Encoder.enum_field(Pbuf.Tests.Everything.Corpus, data.corpus, <<144, 1>>),
      Encoder.oneof_field(:choice_int32, data.choice, 0, fn v -> Encoder.field(:int32, v, <<152, 1>>) end),
      Encoder.oneof_field(:choice_string, data.choice, 0, fn v -> Encoder.field(:string, v, <<162, 1>>) end),
      Encoder.field(:struct, data.user, <<170, 1>>),
      Encoder.enum_field(Pbuf.Tests.Sub.UserStatus, data.user_status, <<176, 1>>),
      Encoder.repeated_field(:bool, data.bools, <<250, 1>>),
      Encoder.repeated_field(:int32, data.int32s, <<130, 2>>),
      Encoder.repeated_field(:int64, data.int64s, <<138, 2>>),
      Encoder.repeated_field(:uint32, data.uint32s, <<146, 2>>),
      Encoder.repeated_field(:uint64, data.uint64s, <<154, 2>>),
      Encoder.repeated_field(:sint32, data.sint32s, <<162, 2>>),
      Encoder.repeated_field(:sint64, data.sint64s, <<170, 2>>),
      Encoder.repeated_field(:fixed32, data.fixed32s, <<178, 2>>),
      Encoder.repeated_field(:sfixed32, data.sfixed32s, <<186, 2>>),
      Encoder.repeated_field(:fixed64, data.fixed64s, <<194, 2>>),
      Encoder.repeated_field(:sfixed64, data.sfixed64s, <<202, 2>>),
      Encoder.repeated_field(:float, data.floats, <<210, 2>>),
      Encoder.repeated_field(:double, data.doubles, <<218, 2>>),
      Encoder.repeated_field(:string, data.strings, <<226, 2>>),
      Encoder.repeated_field(:bytes, data.bytess, <<234, 2>>),
      Encoder.repeated_field(:struct, data.structs, <<242, 2>>),
      Encoder.repeated_enum_field(Pbuf.Tests.EverythingType, data.types, <<250, 2>>),
      Encoder.repeated_enum_field(Pbuf.Tests.Everything.Corpus, data.corpuss, <<130, 3>>),
      Encoder.map_field(<<10>>, :string, <<16>>, :int32, data.map1, <<234, 3>>),
      Encoder.map_field(<<8>>, :int64, <<21>>, :float, data.map2, <<242, 3>>),
      Encoder.map_field(<<8>>, :uint32, <<18>>, :struct, data.map3, <<250, 3>>),
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
    Decoder.field(:bool, :bool, acc, data)
  end
  def decode(acc, <<16, data::binary>>) do
    Decoder.field(:int32, :int32, acc, data)
  end
  def decode(acc, <<24, data::binary>>) do
    Decoder.field(:int64, :int64, acc, data)
  end
  def decode(acc, <<32, data::binary>>) do
    Decoder.field(:uint32, :uint32, acc, data)
  end
  def decode(acc, <<40, data::binary>>) do
    Decoder.field(:uint64, :uint64, acc, data)
  end
  def decode(acc, <<48, data::binary>>) do
    Decoder.field(:sint32, :sint32, acc, data)
  end
  def decode(acc, <<56, data::binary>>) do
    Decoder.field(:sint64, :sint64, acc, data)
  end
  def decode(acc, <<69, data::binary>>) do
    Decoder.field(:fixed32, :fixed32, acc, data)
  end
  def decode(acc, <<73, data::binary>>) do
    Decoder.field(:fixed64, :fixed64, acc, data)
  end
  def decode(acc, <<85, data::binary>>) do
    Decoder.field(:sfixed32, :sfixed32, acc, data)
  end
  def decode(acc, <<89, data::binary>>) do
    Decoder.field(:sfixed64, :sfixed64, acc, data)
  end
  def decode(acc, <<101, data::binary>>) do
    Decoder.field(:float, :float, acc, data)
  end
  def decode(acc, <<105, data::binary>>) do
    Decoder.field(:double, :double, acc, data)
  end
  def decode(acc, <<114, data::binary>>) do
    Decoder.field(:string, :string, acc, data)
  end
  def decode(acc, <<122, data::binary>>) do
    Decoder.field(:bytes, :bytes, acc, data)
  end
  def decode(acc, <<130, 1, data::binary>>) do
    Decoder.struct_field(Pbuf.Tests.Child, :struct, acc, data)
  end
  def decode(acc, <<136, 1, data::binary>>) do
    Decoder.enum_field(Pbuf.Tests.EverythingType, :type, acc, data)
  end
  def decode(acc, <<144, 1, data::binary>>) do
    Decoder.enum_field(Pbuf.Tests.Everything.Corpus, :corpus, acc, data)
  end
  def decode(acc, <<152, 1, data::binary>>) do
    Decoder.oneof_field(:choice, 0, Decoder.field(:int32, :choice_int32, acc, data))
  end
  def decode(acc, <<162, 1, data::binary>>) do
    Decoder.oneof_field(:choice, 0, Decoder.field(:string, :choice_string, acc, data))
  end
  def decode(acc, <<170, 1, data::binary>>) do
    Decoder.struct_field(Pbuf.Tests.Sub.User, :user, acc, data)
  end
  def decode(acc, <<176, 1, data::binary>>) do
    Decoder.enum_field(Pbuf.Tests.Sub.UserStatus, :user_status, acc, data)
  end
  def decode(acc, <<250, 1, data::binary>>) do
    Decoder.repeated_field(:bool, :bools, acc, data)
  end
  def decode(acc, <<130, 2, data::binary>>) do
    Decoder.repeated_field(:int32, :int32s, acc, data)
  end
  def decode(acc, <<138, 2, data::binary>>) do
    Decoder.repeated_field(:int64, :int64s, acc, data)
  end
  def decode(acc, <<146, 2, data::binary>>) do
    Decoder.repeated_field(:uint32, :uint32s, acc, data)
  end
  def decode(acc, <<154, 2, data::binary>>) do
    Decoder.repeated_field(:uint64, :uint64s, acc, data)
  end
  def decode(acc, <<162, 2, data::binary>>) do
    Decoder.repeated_field(:sint32, :sint32s, acc, data)
  end
  def decode(acc, <<170, 2, data::binary>>) do
    Decoder.repeated_field(:sint64, :sint64s, acc, data)
  end
  def decode(acc, <<178, 2, data::binary>>) do
    Decoder.repeated_field(:fixed32, :fixed32s, acc, data)
  end
  def decode(acc, <<186, 2, data::binary>>) do
    Decoder.repeated_field(:sfixed32, :sfixed32s, acc, data)
  end
  def decode(acc, <<194, 2, data::binary>>) do
    Decoder.repeated_field(:fixed64, :fixed64s, acc, data)
  end
  def decode(acc, <<202, 2, data::binary>>) do
    Decoder.repeated_field(:sfixed64, :sfixed64s, acc, data)
  end
  def decode(acc, <<210, 2, data::binary>>) do
    Decoder.repeated_field(:float, :floats, acc, data)
  end
  def decode(acc, <<218, 2, data::binary>>) do
    Decoder.repeated_field(:double, :doubles, acc, data)
  end
  def decode(acc, <<226, 2, data::binary>>) do
    Decoder.field(:string, :strings, acc, data)
  end
  def decode(acc, <<234, 2, data::binary>>) do
    Decoder.field(:bytes, :bytess, acc, data)
  end
  def decode(acc, <<242, 2, data::binary>>) do
    Decoder.struct_field(Pbuf.Tests.Child, :structs, acc, data)
  end
  def decode(acc, <<250, 2, data::binary>>) do
    Decoder.repeated_enum_field(Pbuf.Tests.EverythingType, :types, acc, data)
  end
  def decode(acc, <<130, 3, data::binary>>) do
    Decoder.repeated_enum_field(Pbuf.Tests.Everything.Corpus, :corpuss, acc, data)
  end
  def decode(acc, <<234, 3, data::binary>>) do
    post_map(:map1, 61, Decoder.map_field(10, :string, "", 16, :int32, 0, :map1, acc, data))
  end
  def decode(acc, <<242, 3, data::binary>>) do
    post_map(:map2, 62, Decoder.map_field(8, :int64, 0, 21, :float, 0.0, :map2, acc, data))
  end
  def decode(acc, <<250, 3, data::binary>>) do
    post_map(:map3, 63, Decoder.map_field(8, :uint32, 0, 18, Pbuf.Tests.Child, nil, :map3, acc, data))
  end

  # failed to decode, either this is an unknown tag (which we can skip), or
  # it is a wrong type (which is an error)
  def decode(acc, data) do
    {prefix, data} = Decoder.varint(data)
    tag = bsr(prefix, 3)
    type = band(prefix, 7)
    case tag in [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,61,62,63] do
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
      {:map3, {c, v}}, acc -> Map.update(acc, :map3, %{c => v}, fn m -> Map.put(m, c, v) end)
      {:map2, {c, v}}, acc -> Map.update(acc, :map2, %{c => v}, fn m -> Map.put(m, c, v) end)
      {:map1, {c, v}}, acc -> Map.update(acc, :map1, %{c => v}, fn m -> Map.put(m, c, v) end)
      {:structs, v}, acc -> Map.update(acc, :structs, [v], fn e -> [v | e] end)
      {:bytess, v}, acc -> Map.update(acc, :bytess, [v], fn e -> [v | e] end)
      {:strings, v}, acc -> Map.update(acc, :strings, [v], fn e -> [v | e] end)
      {k, v}, acc -> Map.put(acc, k, v)
    end)
    struct = Map.put(struct, :structs, Elixir.Enum.reverse(struct.structs))
    struct = Map.put(struct, :bytess, Elixir.Enum.reverse(struct.bytess))
    struct = Map.put(struct, :strings, Elixir.Enum.reverse(struct.strings))
    struct
  end
end
defmodule Pbuf.Tests.Child do
  @moduledoc false
  alias Pbuf.Decoder
  import Bitwise, only: [bsr: 2, band: 2]

  
  defstruct [
    id: 0,
    name: "",
    data1: <<>>,
    data2: <<>>,
    data3: <<>>
  ]
  @type t :: %__MODULE__{
    id: non_neg_integer,
    name: String.t,
    data1: binary,
    data2: binary,
    data3: binary
  }
defmodule EverythingType do
  @moduledoc false
  @type t :: :EVERYTHING_TYPE_UNKNOWN | 0 | :EVERYTHING_TYPE_SAND | 1 | :EVERYTHING_TYPE_SPICE | 2
  @spec to_int(t | non_neg_integer) :: integer
  def to_int(:EVERYTHING_TYPE_SAND), do: 1
  def to_int(1), do: 1
  def to_int(:EVERYTHING_TYPE_SPICE), do: 2
  def to_int(2), do: 2
  def to_int(:EVERYTHING_TYPE_UNKNOWN), do: 0
  def to_int(0), do: 0
  def to_int(invalid) do
    raise Pbuf.Encoder.Error,
      type: __MODULE__,
      value: invalid,
      tag: nil,
      message: "#{inspect(invalid)} is not a valid enum value for #{__MODULE__}"
  end
  @spec from_int(integer) :: t
  def from_int(1), do: :EVERYTHING_TYPE_SAND
  def from_int(2), do: :EVERYTHING_TYPE_SPICE
  def from_int(0), do: :EVERYTHING_TYPE_UNKNOWN
  def from_int(_unknown), do: :invalid
end
  @spec new(Enum.t) :: t
  def new(data) do
    struct(__MODULE__, data)
  end
  @spec encode_to_iodata!(t | map) :: iodata
  def encode_to_iodata!(data) do
    alias Elixir.Pbuf.Encoder
    [
      Encoder.field(:uint32, data.id, <<8>>),
      Encoder.field(:string, data.name, <<18>>),
      Encoder.field(:bytes, data.data1, <<26>>),
      
case data.data2 do
        <<>> -> []
        value -> Encoder.field(:bytes, Elixir.Jason.encode!(value), <<34>>)
      end,
      
case data.data3 do
        <<>> -> []
        value -> Encoder.field(:bytes, Elixir.Jason.encode!(value), <<42>>)
      end,
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
    Decoder.field(:uint32, :id, acc, data)
  end
  def decode(acc, <<18, data::binary>>) do
    Decoder.field(:string, :name, acc, data)
  end
  def decode(acc, <<26, data::binary>>) do
    Decoder.field(:bytes, :data1, acc, data)
  end
  def decode(acc, <<34, data::binary>>) do
    Decoder.field(:bytes, :data2, acc, data)
  end
  def decode(acc, <<42, data::binary>>) do
    Decoder.field(:bytes, :data3, acc, data)
  end

  # failed to decode, either this is an unknown tag (which we can skip), or
  # it is a wrong type (which is an error)
  def decode(acc, data) do
    {prefix, data} = Decoder.varint(data)
    tag = bsr(prefix, 3)
    type = band(prefix, 7)
    case tag in [1,2,3,4,5] do
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
        {:data3, v}, acc -> Map.put(acc, :data3, Elixir.Jason.decode!(v, [keys: :atoms]))
        {:data2, v}, acc -> Map.put(acc, :data2, Elixir.Jason.decode!(v, []))
      {k, v}, acc -> Map.put(acc, k, v)
    end)
    struct
  end
end
defmodule Pbuf.Tests.EverythingType do
  @moduledoc false
  @type t :: :EVERYTHING_TYPE_UNKNOWN | 0 | :EVERYTHING_TYPE_SAND | 1 | :EVERYTHING_TYPE_SPICE | 2
  @spec to_int(t | non_neg_integer) :: integer
  def to_int(:EVERYTHING_TYPE_SAND), do: 1
  def to_int(1), do: 1
  def to_int(:EVERYTHING_TYPE_SPICE), do: 2
  def to_int(2), do: 2
  def to_int(:EVERYTHING_TYPE_UNKNOWN), do: 0
  def to_int(0), do: 0
  def to_int(invalid) do
    raise Pbuf.Encoder.Error,
      type: __MODULE__,
      value: invalid,
      tag: nil,
      message: "#{inspect(invalid)} is not a valid enum value for #{__MODULE__}"
  end
  @spec from_int(integer) :: t
  def from_int(1), do: :EVERYTHING_TYPE_SAND
  def from_int(2), do: :EVERYTHING_TYPE_SPICE
  def from_int(0), do: :EVERYTHING_TYPE_UNKNOWN
  def from_int(_unknown), do: :invalid
end
