defmodule Google.Protobuf.Type do
  @moduledoc false
  alias Pbuf.{Decoder, Encoder}
  import Bitwise, only: [bsr: 2, band: 2]

  alias __MODULE__

  defstruct [
    __pbuf__: true,
    name: "",
    fields: [],
    oneofs: [],
    options: [],
    source_context: nil,
    syntax: 0
  ]

  @type t :: %Type{
    name: String.t,
    fields: [Google.Protobuf.Field.t],
    oneofs: [String.t],
    options: [Google.Protobuf.Option.t],
    source_context: Google.Protobuf.SourceContext.t,
    syntax: Google.Protobuf.Syntax.t
  }


  @spec new(Enum.t) :: t
  def new(data) do
    struct(__MODULE__, data)
  end

  @spec encode_to_iodata!(t | map) :: iodata
  def encode_to_iodata!(data) do
    alias Elixir.Pbuf.Encoder
    [
      Encoder.field(:string, data.name, <<10>>),
      Encoder.repeated_field(:struct, data.fields, <<18>>),
      Encoder.repeated_field(:string, data.oneofs, <<26>>),
      Encoder.repeated_field(:struct, data.options, <<34>>),
      Encoder.field(:struct, data.source_context, <<42>>),
      Encoder.enum_field(Google.Protobuf.Syntax, data.syntax, <<48>>),
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
    Decoder.field(:string, :name, acc, data)
  end
  
  def decode(acc, <<18, data::binary>>) do
    Decoder.struct_field(Google.Protobuf.Field, :fields, acc, data)
  end
  
  def decode(acc, <<26, data::binary>>) do
    Decoder.field(:string, :oneofs, acc, data)
  end
  
  def decode(acc, <<34, data::binary>>) do
    Decoder.struct_field(Google.Protobuf.Option, :options, acc, data)
  end
  
  def decode(acc, <<42, data::binary>>) do
    Decoder.struct_field(Google.Protobuf.SourceContext, :source_context, acc, data)
  end
  
  def decode(acc, <<48, data::binary>>) do
    Decoder.enum_field(Google.Protobuf.Syntax, :syntax, acc, data)
  end


  # failed to decode, either this is an unknown tag (which we can skip), or
  # it's a wrong type (which is an error)
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
          message: "#{__MODULE__} tag #{tag} has an incorrect write type of #{type}"
        }
        {:error, err}
    end
  end


  def __finalize_decode__(args) do
    struct = Elixir.Enum.reduce(args, %__MODULE__{}, fn
      
      {:fields, v}, acc -> Map.update(acc, :fields, [v], fn e -> [v | e] end)

      {:oneofs, v}, acc -> Map.update(acc, :oneofs, [v], fn e -> [v | e] end)

      {:options, v}, acc -> Map.update(acc, :options, [v], fn e -> [v | e] end)
      {k, v}, acc -> Map.put(acc, k, v)
    end)

    struct = Map.put(struct, :fields, Elixir.Enum.reverse(struct.fields))
    struct = Map.put(struct, :oneofs, Elixir.Enum.reverse(struct.oneofs))
    struct = Map.put(struct, :options, Elixir.Enum.reverse(struct.options))
    struct
  end
end
defmodule Google.Protobuf.Field do
  @moduledoc false
  alias Pbuf.{Decoder, Encoder}
  import Bitwise, only: [bsr: 2, band: 2]

  alias __MODULE__

  defstruct [
    __pbuf__: true,
    kind: 0,
    cardinality: 0,
    number: 0,
    name: "",
    type_url: "",
    oneof_index: 0,
    packed: false,
    options: [],
    json_name: "",
    default_value: ""
  ]

  @type t :: %Field{
    kind: Google.Protobuf.Field.Kind.t,
    cardinality: Google.Protobuf.Field.Cardinality.t,
    number: integer,
    name: String.t,
    type_url: String.t,
    oneof_index: integer,
    packed: boolean,
    options: [Google.Protobuf.Option.t],
    json_name: String.t,
    default_value: String.t
  }

defmodule Cardinality do
  @moduledoc false
  @type t :: :CARDINALITY_OPTIONAL | :CARDINALITY_REPEATED | :CARDINALITY_REQUIRED | :CARDINALITY_UNKNOWN | non_neg_integer
  @spec to_int(t | non_neg_integer) :: integer
  def to_int(:CARDINALITY_OPTIONAL), do: 1
  def to_int(1), do: 1
  def to_int(:CARDINALITY_REPEATED), do: 3
  def to_int(3), do: 3
  def to_int(:CARDINALITY_REQUIRED), do: 2
  def to_int(2), do: 2
  def to_int(:CARDINALITY_UNKNOWN), do: 0
  def to_int(0), do: 0
  def to_int(invalid) do
    raise Pbuf.Encoder.Error,
      type: __MODULE__,
      value: invalid,
      tag: nil,
      message: "#{inspect(invalid)} is not a valid enum value for #{__MODULE__}"
  end

  @spec from_int(integer) :: t
  def from_int(1), do: :CARDINALITY_OPTIONAL
  def from_int(3), do: :CARDINALITY_REPEATED
  def from_int(2), do: :CARDINALITY_REQUIRED
  def from_int(0), do: :CARDINALITY_UNKNOWN
  def from_int(_unknown), do: :invalid
end

defmodule Kind do
  @moduledoc false
  @type t :: :TYPE_BOOL | :TYPE_BYTES | :TYPE_DOUBLE | :TYPE_ENUM | :TYPE_FIXED32 | :TYPE_FIXED64 | :TYPE_FLOAT | :TYPE_GROUP | :TYPE_INT32 | :TYPE_INT64 | :TYPE_MESSAGE | :TYPE_SFIXED32 | :TYPE_SFIXED64 | :TYPE_SINT32 | :TYPE_SINT64 | :TYPE_STRING | :TYPE_UINT32 | :TYPE_UINT64 | :TYPE_UNKNOWN | non_neg_integer
  @spec to_int(t | non_neg_integer) :: integer
  def to_int(:TYPE_BOOL), do: 8
  def to_int(8), do: 8
  def to_int(:TYPE_BYTES), do: 12
  def to_int(12), do: 12
  def to_int(:TYPE_DOUBLE), do: 1
  def to_int(1), do: 1
  def to_int(:TYPE_ENUM), do: 14
  def to_int(14), do: 14
  def to_int(:TYPE_FIXED32), do: 7
  def to_int(7), do: 7
  def to_int(:TYPE_FIXED64), do: 6
  def to_int(6), do: 6
  def to_int(:TYPE_FLOAT), do: 2
  def to_int(2), do: 2
  def to_int(:TYPE_GROUP), do: 10
  def to_int(10), do: 10
  def to_int(:TYPE_INT32), do: 5
  def to_int(5), do: 5
  def to_int(:TYPE_INT64), do: 3
  def to_int(3), do: 3
  def to_int(:TYPE_MESSAGE), do: 11
  def to_int(11), do: 11
  def to_int(:TYPE_SFIXED32), do: 15
  def to_int(15), do: 15
  def to_int(:TYPE_SFIXED64), do: 16
  def to_int(16), do: 16
  def to_int(:TYPE_SINT32), do: 17
  def to_int(17), do: 17
  def to_int(:TYPE_SINT64), do: 18
  def to_int(18), do: 18
  def to_int(:TYPE_STRING), do: 9
  def to_int(9), do: 9
  def to_int(:TYPE_UINT32), do: 13
  def to_int(13), do: 13
  def to_int(:TYPE_UINT64), do: 4
  def to_int(4), do: 4
  def to_int(:TYPE_UNKNOWN), do: 0
  def to_int(0), do: 0
  def to_int(invalid) do
    raise Pbuf.Encoder.Error,
      type: __MODULE__,
      value: invalid,
      tag: nil,
      message: "#{inspect(invalid)} is not a valid enum value for #{__MODULE__}"
  end

  @spec from_int(integer) :: t
  def from_int(8), do: :TYPE_BOOL
  def from_int(12), do: :TYPE_BYTES
  def from_int(1), do: :TYPE_DOUBLE
  def from_int(14), do: :TYPE_ENUM
  def from_int(7), do: :TYPE_FIXED32
  def from_int(6), do: :TYPE_FIXED64
  def from_int(2), do: :TYPE_FLOAT
  def from_int(10), do: :TYPE_GROUP
  def from_int(5), do: :TYPE_INT32
  def from_int(3), do: :TYPE_INT64
  def from_int(11), do: :TYPE_MESSAGE
  def from_int(15), do: :TYPE_SFIXED32
  def from_int(16), do: :TYPE_SFIXED64
  def from_int(17), do: :TYPE_SINT32
  def from_int(18), do: :TYPE_SINT64
  def from_int(9), do: :TYPE_STRING
  def from_int(13), do: :TYPE_UINT32
  def from_int(4), do: :TYPE_UINT64
  def from_int(0), do: :TYPE_UNKNOWN
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
      Encoder.enum_field(Google.Protobuf.Field.Kind, data.kind, <<8>>),
      Encoder.enum_field(Google.Protobuf.Field.Cardinality, data.cardinality, <<16>>),
      Encoder.field(:int32, data.number, <<24>>),
      Encoder.field(:string, data.name, <<34>>),
      Encoder.field(:string, data.type_url, <<50>>),
      Encoder.field(:int32, data.oneof_index, <<56>>),
      Encoder.field(:bool, data.packed, <<64>>),
      Encoder.repeated_field(:struct, data.options, <<74>>),
      Encoder.field(:string, data.json_name, <<82>>),
      Encoder.field(:string, data.default_value, <<90>>),
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
  
  def decode(acc, <<8, data::binary>>) do
    Decoder.enum_field(Google.Protobuf.Field.Kind, :kind, acc, data)
  end
  
  def decode(acc, <<16, data::binary>>) do
    Decoder.enum_field(Google.Protobuf.Field.Cardinality, :cardinality, acc, data)
  end
  
  def decode(acc, <<24, data::binary>>) do
    Decoder.field(:int32, :number, acc, data)
  end
  
  def decode(acc, <<34, data::binary>>) do
    Decoder.field(:string, :name, acc, data)
  end
  
  def decode(acc, <<50, data::binary>>) do
    Decoder.field(:string, :type_url, acc, data)
  end
  
  def decode(acc, <<56, data::binary>>) do
    Decoder.field(:int32, :oneof_index, acc, data)
  end
  
  def decode(acc, <<64, data::binary>>) do
    Decoder.field(:bool, :packed, acc, data)
  end
  
  def decode(acc, <<74, data::binary>>) do
    Decoder.struct_field(Google.Protobuf.Option, :options, acc, data)
  end
  
  def decode(acc, <<82, data::binary>>) do
    Decoder.field(:string, :json_name, acc, data)
  end
  
  def decode(acc, <<90, data::binary>>) do
    Decoder.field(:string, :default_value, acc, data)
  end


  # failed to decode, either this is an unknown tag (which we can skip), or
  # it's a wrong type (which is an error)
  def decode(acc, data) do
    {prefix, data} = Decoder.varint(data)
    tag = bsr(prefix, 3)
    type = band(prefix, 7)

    case tag in [1,2,3,4,6,7,8,9,10,11] do
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
      
      {:options, v}, acc -> Map.update(acc, :options, [v], fn e -> [v | e] end)
      {k, v}, acc -> Map.put(acc, k, v)
    end)

    struct = Map.put(struct, :options, Elixir.Enum.reverse(struct.options))
    struct
  end
end
defmodule Google.Protobuf.Enum do
  @moduledoc false
  alias Pbuf.{Decoder, Encoder}
  import Bitwise, only: [bsr: 2, band: 2]

  alias __MODULE__

  defstruct [
    __pbuf__: true,
    name: "",
    enumvalue: [],
    options: [],
    source_context: nil,
    syntax: 0
  ]

  @type t :: %Enum{
    name: String.t,
    enumvalue: [Google.Protobuf.EnumValue.t],
    options: [Google.Protobuf.Option.t],
    source_context: Google.Protobuf.SourceContext.t,
    syntax: Google.Protobuf.Syntax.t
  }


  @spec new(Enum.t) :: t
  def new(data) do
    struct(__MODULE__, data)
  end

  @spec encode_to_iodata!(t | map) :: iodata
  def encode_to_iodata!(data) do
    alias Elixir.Pbuf.Encoder
    [
      Encoder.field(:string, data.name, <<10>>),
      Encoder.repeated_field(:struct, data.enumvalue, <<18>>),
      Encoder.repeated_field(:struct, data.options, <<26>>),
      Encoder.field(:struct, data.source_context, <<34>>),
      Encoder.enum_field(Google.Protobuf.Syntax, data.syntax, <<40>>),
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
    Decoder.field(:string, :name, acc, data)
  end
  
  def decode(acc, <<18, data::binary>>) do
    Decoder.struct_field(Google.Protobuf.EnumValue, :enumvalue, acc, data)
  end
  
  def decode(acc, <<26, data::binary>>) do
    Decoder.struct_field(Google.Protobuf.Option, :options, acc, data)
  end
  
  def decode(acc, <<34, data::binary>>) do
    Decoder.struct_field(Google.Protobuf.SourceContext, :source_context, acc, data)
  end
  
  def decode(acc, <<40, data::binary>>) do
    Decoder.enum_field(Google.Protobuf.Syntax, :syntax, acc, data)
  end


  # failed to decode, either this is an unknown tag (which we can skip), or
  # it's a wrong type (which is an error)
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
          message: "#{__MODULE__} tag #{tag} has an incorrect write type of #{type}"
        }
        {:error, err}
    end
  end


  def __finalize_decode__(args) do
    struct = Elixir.Enum.reduce(args, %__MODULE__{}, fn
      
      {:enumvalue, v}, acc -> Map.update(acc, :enumvalue, [v], fn e -> [v | e] end)

      {:options, v}, acc -> Map.update(acc, :options, [v], fn e -> [v | e] end)
      {k, v}, acc -> Map.put(acc, k, v)
    end)

    struct = Map.put(struct, :enumvalue, Elixir.Enum.reverse(struct.enumvalue))
    struct = Map.put(struct, :options, Elixir.Enum.reverse(struct.options))
    struct
  end
end
defmodule Google.Protobuf.EnumValue do
  @moduledoc false
  alias Pbuf.{Decoder, Encoder}
  import Bitwise, only: [bsr: 2, band: 2]

  alias __MODULE__

  defstruct [
    __pbuf__: true,
    name: "",
    number: 0,
    options: []
  ]

  @type t :: %EnumValue{
    name: String.t,
    number: integer,
    options: [Google.Protobuf.Option.t]
  }


  @spec new(Enum.t) :: t
  def new(data) do
    struct(__MODULE__, data)
  end

  @spec encode_to_iodata!(t | map) :: iodata
  def encode_to_iodata!(data) do
    alias Elixir.Pbuf.Encoder
    [
      Encoder.field(:string, data.name, <<10>>),
      Encoder.field(:int32, data.number, <<16>>),
      Encoder.repeated_field(:struct, data.options, <<26>>),
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
    Decoder.field(:string, :name, acc, data)
  end
  
  def decode(acc, <<16, data::binary>>) do
    Decoder.field(:int32, :number, acc, data)
  end
  
  def decode(acc, <<26, data::binary>>) do
    Decoder.struct_field(Google.Protobuf.Option, :options, acc, data)
  end


  # failed to decode, either this is an unknown tag (which we can skip), or
  # it's a wrong type (which is an error)
  def decode(acc, data) do
    {prefix, data} = Decoder.varint(data)
    tag = bsr(prefix, 3)
    type = band(prefix, 7)

    case tag in [1,2,3] do
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
      
      {:options, v}, acc -> Map.update(acc, :options, [v], fn e -> [v | e] end)
      {k, v}, acc -> Map.put(acc, k, v)
    end)

    struct = Map.put(struct, :options, Elixir.Enum.reverse(struct.options))
    struct
  end
end
defmodule Google.Protobuf.Option do
  @moduledoc false
  alias Pbuf.{Decoder, Encoder}
  import Bitwise, only: [bsr: 2, band: 2]

  alias __MODULE__

  defstruct [
    __pbuf__: true,
    name: "",
    value: nil
  ]

  @type t :: %Option{
    name: String.t,
    value: Google.Protobuf.Any.t
  }


  @spec new(Enum.t) :: t
  def new(data) do
    struct(__MODULE__, data)
  end

  @spec encode_to_iodata!(t | map) :: iodata
  def encode_to_iodata!(data) do
    alias Elixir.Pbuf.Encoder
    [
      Encoder.field(:string, data.name, <<10>>),
      Encoder.field(:struct, data.value, <<18>>),
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
    Decoder.field(:string, :name, acc, data)
  end
  
  def decode(acc, <<18, data::binary>>) do
    Decoder.struct_field(Google.Protobuf.Any, :value, acc, data)
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
    struct = Elixir.Enum.reduce(args, %__MODULE__{}, fn
            {k, v}, acc -> Map.put(acc, k, v)
    end)

    struct
  end
end
defmodule Google.Protobuf.Syntax do
  @moduledoc false
  @type t :: :SYNTAX_PROTO2 | :SYNTAX_PROTO3 | non_neg_integer
  @spec to_int(t | non_neg_integer) :: integer
  def to_int(:SYNTAX_PROTO2), do: 0
  def to_int(0), do: 0
  def to_int(:SYNTAX_PROTO3), do: 1
  def to_int(1), do: 1
  def to_int(invalid) do
    raise Pbuf.Encoder.Error,
      type: __MODULE__,
      value: invalid,
      tag: nil,
      message: "#{inspect(invalid)} is not a valid enum value for #{__MODULE__}"
  end

  @spec from_int(integer) :: t
  def from_int(0), do: :SYNTAX_PROTO2
  def from_int(1), do: :SYNTAX_PROTO3
  def from_int(_unknown), do: :invalid
end
