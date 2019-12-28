defmodule Google.Protobuf.FileDescriptorSet do
  @moduledoc false
  alias Pbuf.Decoder
  import Bitwise, only: [bsr: 2, band: 2]

  @derive Jason.Encoder
  defstruct [
    file: []
  ]
  @type t :: %__MODULE__{
    file: [Google.Protobuf.FileDescriptorProto.t]
  }

  @spec new(Enum.t) :: t
  def new(data \\ []) do
    struct(__MODULE__, data)
  end
  @spec encode_to_iodata!(t | map) :: iodata
  def encode_to_iodata!(data) do
    alias Elixir.Pbuf.Encoder
    [
      Encoder.repeated_unpacked_field(:struct, data.file, <<10>>),
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
    Decoder.struct_field(Google.Protobuf.FileDescriptorProto, :file, acc, data)
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
      {:file, v}, acc -> Map.update(acc, :file, [v], fn e -> [v | e] end)
      {k, v}, acc -> Map.put(acc, k, v)
    end)
    struct = Map.put(struct, :file, Elixir.Enum.reverse(struct.file))
    struct
  end
end
defmodule Google.Protobuf.FileDescriptorProto do
  @moduledoc false
  alias Pbuf.Decoder
  import Bitwise, only: [bsr: 2, band: 2]

  @derive Jason.Encoder
  defstruct [
    name: nil,
    package: nil,
    dependency: [],
    message_type: [],
    enum_type: [],
    service: [],
    extension: [],
    options: nil,
    source_code_info: nil,
    public_dependency: [],
    weak_dependency: [],
    syntax: nil
  ]
  @type t :: %__MODULE__{
    name: String.t,
    package: String.t,
    dependency: [String.t],
    message_type: [Google.Protobuf.DescriptorProto.t],
    enum_type: [Google.Protobuf.EnumDescriptorProto.t],
    service: [Google.Protobuf.ServiceDescriptorProto.t],
    extension: [Google.Protobuf.FieldDescriptorProto.t],
    options: Google.Protobuf.FileOptions.t,
    source_code_info: Google.Protobuf.SourceCodeInfo.t,
    public_dependency: [integer],
    weak_dependency: [integer],
    syntax: String.t
  }

  @spec new(Enum.t) :: t
  def new(data \\ []) do
    struct(__MODULE__, data)
  end
  @spec encode_to_iodata!(t | map) :: iodata
  def encode_to_iodata!(data) do
    alias Elixir.Pbuf.Encoder
    [
      Encoder.field(:string, data.name, <<10>>),
      Encoder.field(:string, data.package, <<18>>),
      Encoder.repeated_unpacked_field(:string, data.dependency, <<26>>),
      Encoder.repeated_unpacked_field(:struct, data.message_type, <<34>>),
      Encoder.repeated_unpacked_field(:struct, data.enum_type, <<42>>),
      Encoder.repeated_unpacked_field(:struct, data.service, <<50>>),
      Encoder.repeated_unpacked_field(:struct, data.extension, <<58>>),
      Encoder.field(:struct, data.options, <<66>>),
      Encoder.field(:struct, data.source_code_info, <<74>>),
      Encoder.repeated_unpacked_field(:int32, data.public_dependency, <<80>>),
      Encoder.repeated_unpacked_field(:int32, data.weak_dependency, <<88>>),
      Encoder.field(:string, data.syntax, <<98>>),
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
    Decoder.field(:string, :name, acc, data)
  end
  def decode(acc, <<18, data::binary>>) do
    Decoder.field(:string, :package, acc, data)
  end
  def decode(acc, <<26, data::binary>>) do
    Decoder.field(:string, :dependency, acc, data)
  end
  def decode(acc, <<34, data::binary>>) do
    Decoder.struct_field(Google.Protobuf.DescriptorProto, :message_type, acc, data)
  end
  def decode(acc, <<42, data::binary>>) do
    Decoder.struct_field(Google.Protobuf.EnumDescriptorProto, :enum_type, acc, data)
  end
  def decode(acc, <<50, data::binary>>) do
    Decoder.struct_field(Google.Protobuf.ServiceDescriptorProto, :service, acc, data)
  end
  def decode(acc, <<58, data::binary>>) do
    Decoder.struct_field(Google.Protobuf.FieldDescriptorProto, :extension, acc, data)
  end
  def decode(acc, <<66, data::binary>>) do
    Decoder.struct_field(Google.Protobuf.FileOptions, :options, acc, data)
  end
  def decode(acc, <<74, data::binary>>) do
    Decoder.struct_field(Google.Protobuf.SourceCodeInfo, :source_code_info, acc, data)
  end
  def decode(acc, <<80, data::binary>>) do
    Decoder.repeated_unpacked_field(:int32, :public_dependency, acc, data)
  end
  def decode(acc, <<88, data::binary>>) do
    Decoder.repeated_unpacked_field(:int32, :weak_dependency, acc, data)
  end
  def decode(acc, <<98, data::binary>>) do
    Decoder.field(:string, :syntax, acc, data)
  end

  # failed to decode, either this is an unknown tag (which we can skip), or
  # it is a wrong type (which is an error)
  def decode(acc, data) do
    {prefix, data} = Decoder.varint(data)
    tag = bsr(prefix, 3)
    type = band(prefix, 7)
    case tag in [1,2,3,4,5,6,7,8,9,10,11,12] do
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
      {:weak_dependency, v}, acc -> Map.update(acc, :weak_dependency, [v], fn e -> [v | e] end)
      {:public_dependency, v}, acc -> Map.update(acc, :public_dependency, [v], fn e -> [v | e] end)
      {:extension, v}, acc -> Map.update(acc, :extension, [v], fn e -> [v | e] end)
      {:service, v}, acc -> Map.update(acc, :service, [v], fn e -> [v | e] end)
      {:enum_type, v}, acc -> Map.update(acc, :enum_type, [v], fn e -> [v | e] end)
      {:message_type, v}, acc -> Map.update(acc, :message_type, [v], fn e -> [v | e] end)
      {:dependency, v}, acc -> Map.update(acc, :dependency, [v], fn e -> [v | e] end)
      {k, v}, acc -> Map.put(acc, k, v)
    end)
    struct = Map.put(struct, :weak_dependency, Elixir.Enum.reverse(struct.weak_dependency))
    struct = Map.put(struct, :public_dependency, Elixir.Enum.reverse(struct.public_dependency))
    struct = Map.put(struct, :extension, Elixir.Enum.reverse(struct.extension))
    struct = Map.put(struct, :service, Elixir.Enum.reverse(struct.service))
    struct = Map.put(struct, :enum_type, Elixir.Enum.reverse(struct.enum_type))
    struct = Map.put(struct, :message_type, Elixir.Enum.reverse(struct.message_type))
    struct = Map.put(struct, :dependency, Elixir.Enum.reverse(struct.dependency))
    struct
  end
end
defmodule Google.Protobuf.DescriptorProto do
  @moduledoc false
  alias Pbuf.Decoder
  import Bitwise, only: [bsr: 2, band: 2]

  @derive Jason.Encoder
  defstruct [
    name: nil,
    field: [],
    nested_type: [],
    enum_type: [],
    extension_range: [],
    extension: [],
    options: nil,
    oneof_decl: [],
    reserved_range: [],
    reserved_name: []
  ]
  @type t :: %__MODULE__{
    name: String.t,
    field: [Google.Protobuf.FieldDescriptorProto.t],
    nested_type: [Google.Protobuf.DescriptorProto.t],
    enum_type: [Google.Protobuf.EnumDescriptorProto.t],
    extension_range: [Google.Protobuf.DescriptorProto.ExtensionRange.t],
    extension: [Google.Protobuf.FieldDescriptorProto.t],
    options: Google.Protobuf.MessageOptions.t,
    oneof_decl: [Google.Protobuf.OneofDescriptorProto.t],
    reserved_range: [Google.Protobuf.DescriptorProto.ReservedRange.t],
    reserved_name: [String.t]
  }

  @spec new(Enum.t) :: t
  def new(data \\ []) do
    struct(__MODULE__, data)
  end
  @spec encode_to_iodata!(t | map) :: iodata
  def encode_to_iodata!(data) do
    alias Elixir.Pbuf.Encoder
    [
      Encoder.field(:string, data.name, <<10>>),
      Encoder.repeated_unpacked_field(:struct, data.field, <<18>>),
      Encoder.repeated_unpacked_field(:struct, data.nested_type, <<26>>),
      Encoder.repeated_unpacked_field(:struct, data.enum_type, <<34>>),
      Encoder.repeated_unpacked_field(:struct, data.extension_range, <<42>>),
      Encoder.repeated_unpacked_field(:struct, data.extension, <<50>>),
      Encoder.field(:struct, data.options, <<58>>),
      Encoder.repeated_unpacked_field(:struct, data.oneof_decl, <<66>>),
      Encoder.repeated_unpacked_field(:struct, data.reserved_range, <<74>>),
      Encoder.repeated_unpacked_field(:string, data.reserved_name, <<82>>),
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
    Decoder.field(:string, :name, acc, data)
  end
  def decode(acc, <<18, data::binary>>) do
    Decoder.struct_field(Google.Protobuf.FieldDescriptorProto, :field, acc, data)
  end
  def decode(acc, <<26, data::binary>>) do
    Decoder.struct_field(Google.Protobuf.DescriptorProto, :nested_type, acc, data)
  end
  def decode(acc, <<34, data::binary>>) do
    Decoder.struct_field(Google.Protobuf.EnumDescriptorProto, :enum_type, acc, data)
  end
  def decode(acc, <<42, data::binary>>) do
    Decoder.struct_field(Google.Protobuf.DescriptorProto.ExtensionRange, :extension_range, acc, data)
  end
  def decode(acc, <<50, data::binary>>) do
    Decoder.struct_field(Google.Protobuf.FieldDescriptorProto, :extension, acc, data)
  end
  def decode(acc, <<58, data::binary>>) do
    Decoder.struct_field(Google.Protobuf.MessageOptions, :options, acc, data)
  end
  def decode(acc, <<66, data::binary>>) do
    Decoder.struct_field(Google.Protobuf.OneofDescriptorProto, :oneof_decl, acc, data)
  end
  def decode(acc, <<74, data::binary>>) do
    Decoder.struct_field(Google.Protobuf.DescriptorProto.ReservedRange, :reserved_range, acc, data)
  end
  def decode(acc, <<82, data::binary>>) do
    Decoder.field(:string, :reserved_name, acc, data)
  end

  # failed to decode, either this is an unknown tag (which we can skip), or
  # it is a wrong type (which is an error)
  def decode(acc, data) do
    {prefix, data} = Decoder.varint(data)
    tag = bsr(prefix, 3)
    type = band(prefix, 7)
    case tag in [1,2,3,4,5,6,7,8,9,10] do
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
      {:reserved_name, v}, acc -> Map.update(acc, :reserved_name, [v], fn e -> [v | e] end)
      {:reserved_range, v}, acc -> Map.update(acc, :reserved_range, [v], fn e -> [v | e] end)
      {:oneof_decl, v}, acc -> Map.update(acc, :oneof_decl, [v], fn e -> [v | e] end)
      {:extension, v}, acc -> Map.update(acc, :extension, [v], fn e -> [v | e] end)
      {:extension_range, v}, acc -> Map.update(acc, :extension_range, [v], fn e -> [v | e] end)
      {:enum_type, v}, acc -> Map.update(acc, :enum_type, [v], fn e -> [v | e] end)
      {:nested_type, v}, acc -> Map.update(acc, :nested_type, [v], fn e -> [v | e] end)
      {:field, v}, acc -> Map.update(acc, :field, [v], fn e -> [v | e] end)
      {k, v}, acc -> Map.put(acc, k, v)
    end)
    struct = Map.put(struct, :reserved_name, Elixir.Enum.reverse(struct.reserved_name))
    struct = Map.put(struct, :reserved_range, Elixir.Enum.reverse(struct.reserved_range))
    struct = Map.put(struct, :oneof_decl, Elixir.Enum.reverse(struct.oneof_decl))
    struct = Map.put(struct, :extension, Elixir.Enum.reverse(struct.extension))
    struct = Map.put(struct, :extension_range, Elixir.Enum.reverse(struct.extension_range))
    struct = Map.put(struct, :enum_type, Elixir.Enum.reverse(struct.enum_type))
    struct = Map.put(struct, :nested_type, Elixir.Enum.reverse(struct.nested_type))
    struct = Map.put(struct, :field, Elixir.Enum.reverse(struct.field))
    struct
  end
end
defmodule Google.Protobuf.DescriptorProto.ExtensionRange do
  @moduledoc false
  alias Pbuf.Decoder
  import Bitwise, only: [bsr: 2, band: 2]

  @derive Jason.Encoder
  defstruct [
    start: nil,
    end: nil,
    options: nil
  ]
  @type t :: %__MODULE__{
    start: integer,
    end: integer,
    options: Google.Protobuf.ExtensionRangeOptions.t
  }

  @spec new(Enum.t) :: t
  def new(data \\ []) do
    struct(__MODULE__, data)
  end
  @spec encode_to_iodata!(t | map) :: iodata
  def encode_to_iodata!(data) do
    alias Elixir.Pbuf.Encoder
    [
      Encoder.field(:int32, data.start, <<8>>),
      Encoder.field(:int32, data.end, <<16>>),
      Encoder.field(:struct, data.options, <<26>>),
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
    Decoder.field(:int32, :start, acc, data)
  end
  def decode(acc, <<16, data::binary>>) do
    Decoder.field(:int32, :end, acc, data)
  end
  def decode(acc, <<26, data::binary>>) do
    Decoder.struct_field(Google.Protobuf.ExtensionRangeOptions, :options, acc, data)
  end

  # failed to decode, either this is an unknown tag (which we can skip), or
  # it is a wrong type (which is an error)
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
defmodule Google.Protobuf.DescriptorProto.ReservedRange do
  @moduledoc false
  alias Pbuf.Decoder
  import Bitwise, only: [bsr: 2, band: 2]

  @derive Jason.Encoder
  defstruct [
    start: nil,
    end: nil
  ]
  @type t :: %__MODULE__{
    start: integer,
    end: integer
  }

  @spec new(Enum.t) :: t
  def new(data \\ []) do
    struct(__MODULE__, data)
  end
  @spec encode_to_iodata!(t | map) :: iodata
  def encode_to_iodata!(data) do
    alias Elixir.Pbuf.Encoder
    [
      Encoder.field(:int32, data.start, <<8>>),
      Encoder.field(:int32, data.end, <<16>>),
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
    Decoder.field(:int32, :start, acc, data)
  end
  def decode(acc, <<16, data::binary>>) do
    Decoder.field(:int32, :end, acc, data)
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
defmodule Google.Protobuf.ExtensionRangeOptions do
  @moduledoc false
  alias Pbuf.Decoder
  import Bitwise, only: [bsr: 2, band: 2]

  @derive Jason.Encoder
  defstruct [
    uninterpreted_option: []
  ]
  @type t :: %__MODULE__{
    uninterpreted_option: [Google.Protobuf.UninterpretedOption.t]
  }

  @spec new(Enum.t) :: t
  def new(data \\ []) do
    struct(__MODULE__, data)
  end
  @spec encode_to_iodata!(t | map) :: iodata
  def encode_to_iodata!(data) do
    alias Elixir.Pbuf.Encoder
    [
      Encoder.repeated_unpacked_field(:struct, data.uninterpreted_option, <<186, 62>>),
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
  def decode(acc, <<186, 62, data::binary>>) do
    Decoder.struct_field(Google.Protobuf.UninterpretedOption, :uninterpreted_option, acc, data)
  end

  # failed to decode, either this is an unknown tag (which we can skip), or
  # it is a wrong type (which is an error)
  def decode(acc, data) do
    {prefix, data} = Decoder.varint(data)
    tag = bsr(prefix, 3)
    type = band(prefix, 7)
    case tag in [999] do
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
      {:uninterpreted_option, v}, acc -> Map.update(acc, :uninterpreted_option, [v], fn e -> [v | e] end)
      {k, v}, acc -> Map.put(acc, k, v)
    end)
    struct = Map.put(struct, :uninterpreted_option, Elixir.Enum.reverse(struct.uninterpreted_option))
    struct
  end
end
defmodule Google.Protobuf.FieldDescriptorProto do
  @moduledoc false
  alias Pbuf.Decoder
  import Bitwise, only: [bsr: 2, band: 2]

  @derive Jason.Encoder
  defstruct [
    name: nil,
    extendee: nil,
    number: nil,
    label: :0,
    type: :0,
    type_name: nil,
    default_value: nil,
    options: nil,
    oneof_index: nil,
    json_name: nil
  ]
  @type t :: %__MODULE__{
    name: String.t,
    extendee: String.t,
    number: integer,
    label: Google.Protobuf.FieldDescriptorProto.Label.t,
    type: Google.Protobuf.FieldDescriptorProto.Type.t,
    type_name: String.t,
    default_value: String.t,
    options: Google.Protobuf.FieldOptions.t,
    oneof_index: integer,
    json_name: String.t
  }
defmodule Label do
  @moduledoc false
  @type t :: :LABEL_OPTIONAL | 1 | :LABEL_REQUIRED | 2 | :LABEL_REPEATED | 3
  @spec to_int(t | non_neg_integer) :: integer
  def to_int(:LABEL_OPTIONAL), do: 1
  def to_int(1), do: 1
  def to_int(:LABEL_REPEATED), do: 3
  def to_int(3), do: 3
  def to_int(:LABEL_REQUIRED), do: 2
  def to_int(2), do: 2
  def to_int(invalid) do
    raise Pbuf.Encoder.Error,
      type: __MODULE__,
      value: invalid,
      tag: nil,
      message: "#{inspect(invalid)} is not a valid enum value for #{__MODULE__}"
  end
  @spec from_int(integer) :: t
  def from_int(1), do: :LABEL_OPTIONAL
  def from_int(3), do: :LABEL_REPEATED
  def from_int(2), do: :LABEL_REQUIRED
  def from_int(_unknown), do: :invalid
end
defmodule Type do
  @moduledoc false
  @type t :: :TYPE_DOUBLE | 1 | :TYPE_FLOAT | 2 | :TYPE_INT64 | 3 | :TYPE_UINT64 | 4 | :TYPE_INT32 | 5 | :TYPE_FIXED64 | 6 | :TYPE_FIXED32 | 7 | :TYPE_BOOL | 8 | :TYPE_STRING | 9 | :TYPE_GROUP | 10 | :TYPE_MESSAGE | 11 | :TYPE_BYTES | 12 | :TYPE_UINT32 | 13 | :TYPE_ENUM | 14 | :TYPE_SFIXED32 | 15 | :TYPE_SFIXED64 | 16 | :TYPE_SINT32 | 17 | :TYPE_SINT64 | 18
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
  def from_int(_unknown), do: :invalid
end
  @spec new(Enum.t) :: t
  def new(data \\ []) do
    struct(__MODULE__, data)
  end
  @spec encode_to_iodata!(t | map) :: iodata
  def encode_to_iodata!(data) do
    alias Elixir.Pbuf.Encoder
    [
      Encoder.field(:string, data.name, <<10>>),
      Encoder.field(:string, data.extendee, <<18>>),
      Encoder.field(:int32, data.number, <<24>>),
      Encoder.enum_field(Google.Protobuf.FieldDescriptorProto.Label, data.label, <<32>>),
      Encoder.enum_field(Google.Protobuf.FieldDescriptorProto.Type, data.type, <<40>>),
      Encoder.field(:string, data.type_name, <<50>>),
      Encoder.field(:string, data.default_value, <<58>>),
      Encoder.field(:struct, data.options, <<66>>),
      Encoder.field(:int32, data.oneof_index, <<72>>),
      Encoder.field(:string, data.json_name, <<82>>),
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
    Decoder.field(:string, :name, acc, data)
  end
  def decode(acc, <<18, data::binary>>) do
    Decoder.field(:string, :extendee, acc, data)
  end
  def decode(acc, <<24, data::binary>>) do
    Decoder.field(:int32, :number, acc, data)
  end
  def decode(acc, <<32, data::binary>>) do
    Decoder.enum_field(Google.Protobuf.FieldDescriptorProto.Label, :label, acc, data)
  end
  def decode(acc, <<40, data::binary>>) do
    Decoder.enum_field(Google.Protobuf.FieldDescriptorProto.Type, :type, acc, data)
  end
  def decode(acc, <<50, data::binary>>) do
    Decoder.field(:string, :type_name, acc, data)
  end
  def decode(acc, <<58, data::binary>>) do
    Decoder.field(:string, :default_value, acc, data)
  end
  def decode(acc, <<66, data::binary>>) do
    Decoder.struct_field(Google.Protobuf.FieldOptions, :options, acc, data)
  end
  def decode(acc, <<72, data::binary>>) do
    Decoder.field(:int32, :oneof_index, acc, data)
  end
  def decode(acc, <<82, data::binary>>) do
    Decoder.field(:string, :json_name, acc, data)
  end

  # failed to decode, either this is an unknown tag (which we can skip), or
  # it is a wrong type (which is an error)
  def decode(acc, data) do
    {prefix, data} = Decoder.varint(data)
    tag = bsr(prefix, 3)
    type = band(prefix, 7)
    case tag in [1,2,3,4,5,6,7,8,9,10] do
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
defmodule Google.Protobuf.OneofDescriptorProto do
  @moduledoc false
  alias Pbuf.Decoder
  import Bitwise, only: [bsr: 2, band: 2]

  @derive Jason.Encoder
  defstruct [
    name: nil,
    options: nil
  ]
  @type t :: %__MODULE__{
    name: String.t,
    options: Google.Protobuf.OneofOptions.t
  }

  @spec new(Enum.t) :: t
  def new(data \\ []) do
    struct(__MODULE__, data)
  end
  @spec encode_to_iodata!(t | map) :: iodata
  def encode_to_iodata!(data) do
    alias Elixir.Pbuf.Encoder
    [
      Encoder.field(:string, data.name, <<10>>),
      Encoder.field(:struct, data.options, <<18>>),
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
    Decoder.field(:string, :name, acc, data)
  end
  def decode(acc, <<18, data::binary>>) do
    Decoder.struct_field(Google.Protobuf.OneofOptions, :options, acc, data)
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
defmodule Google.Protobuf.EnumDescriptorProto do
  @moduledoc false
  alias Pbuf.Decoder
  import Bitwise, only: [bsr: 2, band: 2]

  @derive Jason.Encoder
  defstruct [
    name: nil,
    value: [],
    options: nil,
    reserved_range: [],
    reserved_name: []
  ]
  @type t :: %__MODULE__{
    name: String.t,
    value: [Google.Protobuf.EnumValueDescriptorProto.t],
    options: Google.Protobuf.EnumOptions.t,
    reserved_range: [Google.Protobuf.EnumDescriptorProto.EnumReservedRange.t],
    reserved_name: [String.t]
  }

  @spec new(Enum.t) :: t
  def new(data \\ []) do
    struct(__MODULE__, data)
  end
  @spec encode_to_iodata!(t | map) :: iodata
  def encode_to_iodata!(data) do
    alias Elixir.Pbuf.Encoder
    [
      Encoder.field(:string, data.name, <<10>>),
      Encoder.repeated_unpacked_field(:struct, data.value, <<18>>),
      Encoder.field(:struct, data.options, <<26>>),
      Encoder.repeated_unpacked_field(:struct, data.reserved_range, <<34>>),
      Encoder.repeated_unpacked_field(:string, data.reserved_name, <<42>>),
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
    Decoder.field(:string, :name, acc, data)
  end
  def decode(acc, <<18, data::binary>>) do
    Decoder.struct_field(Google.Protobuf.EnumValueDescriptorProto, :value, acc, data)
  end
  def decode(acc, <<26, data::binary>>) do
    Decoder.struct_field(Google.Protobuf.EnumOptions, :options, acc, data)
  end
  def decode(acc, <<34, data::binary>>) do
    Decoder.struct_field(Google.Protobuf.EnumDescriptorProto.EnumReservedRange, :reserved_range, acc, data)
  end
  def decode(acc, <<42, data::binary>>) do
    Decoder.field(:string, :reserved_name, acc, data)
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
      {:reserved_name, v}, acc -> Map.update(acc, :reserved_name, [v], fn e -> [v | e] end)
      {:reserved_range, v}, acc -> Map.update(acc, :reserved_range, [v], fn e -> [v | e] end)
      {:value, v}, acc -> Map.update(acc, :value, [v], fn e -> [v | e] end)
      {k, v}, acc -> Map.put(acc, k, v)
    end)
    struct = Map.put(struct, :reserved_name, Elixir.Enum.reverse(struct.reserved_name))
    struct = Map.put(struct, :reserved_range, Elixir.Enum.reverse(struct.reserved_range))
    struct = Map.put(struct, :value, Elixir.Enum.reverse(struct.value))
    struct
  end
end
defmodule Google.Protobuf.EnumDescriptorProto.EnumReservedRange do
  @moduledoc false
  alias Pbuf.Decoder
  import Bitwise, only: [bsr: 2, band: 2]

  @derive Jason.Encoder
  defstruct [
    start: nil,
    end: nil
  ]
  @type t :: %__MODULE__{
    start: integer,
    end: integer
  }

  @spec new(Enum.t) :: t
  def new(data \\ []) do
    struct(__MODULE__, data)
  end
  @spec encode_to_iodata!(t | map) :: iodata
  def encode_to_iodata!(data) do
    alias Elixir.Pbuf.Encoder
    [
      Encoder.field(:int32, data.start, <<8>>),
      Encoder.field(:int32, data.end, <<16>>),
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
    Decoder.field(:int32, :start, acc, data)
  end
  def decode(acc, <<16, data::binary>>) do
    Decoder.field(:int32, :end, acc, data)
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
defmodule Google.Protobuf.EnumValueDescriptorProto do
  @moduledoc false
  alias Pbuf.Decoder
  import Bitwise, only: [bsr: 2, band: 2]

  @derive Jason.Encoder
  defstruct [
    name: nil,
    number: nil,
    options: nil
  ]
  @type t :: %__MODULE__{
    name: String.t,
    number: integer,
    options: Google.Protobuf.EnumValueOptions.t
  }

  @spec new(Enum.t) :: t
  def new(data \\ []) do
    struct(__MODULE__, data)
  end
  @spec encode_to_iodata!(t | map) :: iodata
  def encode_to_iodata!(data) do
    alias Elixir.Pbuf.Encoder
    [
      Encoder.field(:string, data.name, <<10>>),
      Encoder.field(:int32, data.number, <<16>>),
      Encoder.field(:struct, data.options, <<26>>),
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
    Decoder.field(:string, :name, acc, data)
  end
  def decode(acc, <<16, data::binary>>) do
    Decoder.field(:int32, :number, acc, data)
  end
  def decode(acc, <<26, data::binary>>) do
    Decoder.struct_field(Google.Protobuf.EnumValueOptions, :options, acc, data)
  end

  # failed to decode, either this is an unknown tag (which we can skip), or
  # it is a wrong type (which is an error)
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
defmodule Google.Protobuf.ServiceDescriptorProto do
  @moduledoc false
  alias Pbuf.Decoder
  import Bitwise, only: [bsr: 2, band: 2]

  @derive Jason.Encoder
  defstruct [
    name: nil,
    method: [],
    options: nil
  ]
  @type t :: %__MODULE__{
    name: String.t,
    method: [Google.Protobuf.MethodDescriptorProto.t],
    options: Google.Protobuf.ServiceOptions.t
  }

  @spec new(Enum.t) :: t
  def new(data \\ []) do
    struct(__MODULE__, data)
  end
  @spec encode_to_iodata!(t | map) :: iodata
  def encode_to_iodata!(data) do
    alias Elixir.Pbuf.Encoder
    [
      Encoder.field(:string, data.name, <<10>>),
      Encoder.repeated_unpacked_field(:struct, data.method, <<18>>),
      Encoder.field(:struct, data.options, <<26>>),
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
    Decoder.field(:string, :name, acc, data)
  end
  def decode(acc, <<18, data::binary>>) do
    Decoder.struct_field(Google.Protobuf.MethodDescriptorProto, :method, acc, data)
  end
  def decode(acc, <<26, data::binary>>) do
    Decoder.struct_field(Google.Protobuf.ServiceOptions, :options, acc, data)
  end

  # failed to decode, either this is an unknown tag (which we can skip), or
  # it is a wrong type (which is an error)
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
          message: "#{__MODULE__} tag #{tag} has an incorrect type of #{type}"
        }
        {:error, err}
    end
  end

  def __finalize_decode__(args) do
    struct = Elixir.Enum.reduce(args, %__MODULE__{}, fn
      {:method, v}, acc -> Map.update(acc, :method, [v], fn e -> [v | e] end)
      {k, v}, acc -> Map.put(acc, k, v)
    end)
    struct = Map.put(struct, :method, Elixir.Enum.reverse(struct.method))
    struct
  end
end
defmodule Google.Protobuf.MethodDescriptorProto do
  @moduledoc false
  alias Pbuf.Decoder
  import Bitwise, only: [bsr: 2, band: 2]

  @derive Jason.Encoder
  defstruct [
    name: nil,
    input_type: nil,
    output_type: nil,
    options: nil,
    client_streaming: nil,
    server_streaming: nil
  ]
  @type t :: %__MODULE__{
    name: String.t,
    input_type: String.t,
    output_type: String.t,
    options: Google.Protobuf.MethodOptions.t,
    client_streaming: boolean,
    server_streaming: boolean
  }

  @spec new(Enum.t) :: t
  def new(data \\ []) do
    struct(__MODULE__, data)
  end
  @spec encode_to_iodata!(t | map) :: iodata
  def encode_to_iodata!(data) do
    alias Elixir.Pbuf.Encoder
    [
      Encoder.field(:string, data.name, <<10>>),
      Encoder.field(:string, data.input_type, <<18>>),
      Encoder.field(:string, data.output_type, <<26>>),
      Encoder.field(:struct, data.options, <<34>>),
      Encoder.field(:bool, data.client_streaming, <<40>>),
      Encoder.field(:bool, data.server_streaming, <<48>>),
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
    Decoder.field(:string, :name, acc, data)
  end
  def decode(acc, <<18, data::binary>>) do
    Decoder.field(:string, :input_type, acc, data)
  end
  def decode(acc, <<26, data::binary>>) do
    Decoder.field(:string, :output_type, acc, data)
  end
  def decode(acc, <<34, data::binary>>) do
    Decoder.struct_field(Google.Protobuf.MethodOptions, :options, acc, data)
  end
  def decode(acc, <<40, data::binary>>) do
    Decoder.field(:bool, :client_streaming, acc, data)
  end
  def decode(acc, <<48, data::binary>>) do
    Decoder.field(:bool, :server_streaming, acc, data)
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
defmodule Google.Protobuf.FileOptions do
  @moduledoc false
  alias Pbuf.Decoder
  import Bitwise, only: [bsr: 2, band: 2]

  @derive Jason.Encoder
  defstruct [
    java_package: nil,
    java_outer_classname: nil,
    optimize_for: :0,
    java_multiple_files: nil,
    go_package: nil,
    cc_generic_services: nil,
    java_generic_services: nil,
    py_generic_services: nil,
    java_generate_equals_and_hash: nil,
    deprecated: nil,
    java_string_check_utf8: nil,
    cc_enable_arenas: nil,
    objc_class_prefix: nil,
    csharp_namespace: nil,
    swift_prefix: nil,
    php_class_prefix: nil,
    php_namespace: nil,
    php_generic_services: nil,
    php_metadata_namespace: nil,
    ruby_package: nil,
    uninterpreted_option: []
  ]
  @type t :: %__MODULE__{
    java_package: String.t,
    java_outer_classname: String.t,
    optimize_for: Google.Protobuf.FileOptions.OptimizeMode.t,
    java_multiple_files: boolean,
    go_package: String.t,
    cc_generic_services: boolean,
    java_generic_services: boolean,
    py_generic_services: boolean,
    java_generate_equals_and_hash: boolean,
    deprecated: boolean,
    java_string_check_utf8: boolean,
    cc_enable_arenas: boolean,
    objc_class_prefix: String.t,
    csharp_namespace: String.t,
    swift_prefix: String.t,
    php_class_prefix: String.t,
    php_namespace: String.t,
    php_generic_services: boolean,
    php_metadata_namespace: String.t,
    ruby_package: String.t,
    uninterpreted_option: [Google.Protobuf.UninterpretedOption.t]
  }
defmodule OptimizeMode do
  @moduledoc false
  @type t :: :SPEED | 1 | :CODE_SIZE | 2 | :LITE_RUNTIME | 3
  @spec to_int(t | non_neg_integer) :: integer
  def to_int(:CODE_SIZE), do: 2
  def to_int(2), do: 2
  def to_int(:LITE_RUNTIME), do: 3
  def to_int(3), do: 3
  def to_int(:SPEED), do: 1
  def to_int(1), do: 1
  def to_int(invalid) do
    raise Pbuf.Encoder.Error,
      type: __MODULE__,
      value: invalid,
      tag: nil,
      message: "#{inspect(invalid)} is not a valid enum value for #{__MODULE__}"
  end
  @spec from_int(integer) :: t
  def from_int(2), do: :CODE_SIZE
  def from_int(3), do: :LITE_RUNTIME
  def from_int(1), do: :SPEED
  def from_int(_unknown), do: :invalid
end
  @spec new(Enum.t) :: t
  def new(data \\ []) do
    struct(__MODULE__, data)
  end
  @spec encode_to_iodata!(t | map) :: iodata
  def encode_to_iodata!(data) do
    alias Elixir.Pbuf.Encoder
    [
      Encoder.field(:string, data.java_package, <<10>>),
      Encoder.field(:string, data.java_outer_classname, <<66>>),
      Encoder.enum_field(Google.Protobuf.FileOptions.OptimizeMode, data.optimize_for, <<72>>),
      Encoder.field(:bool, data.java_multiple_files, <<80>>),
      Encoder.field(:string, data.go_package, <<90>>),
      Encoder.field(:bool, data.cc_generic_services, <<128, 1>>),
      Encoder.field(:bool, data.java_generic_services, <<136, 1>>),
      Encoder.field(:bool, data.py_generic_services, <<144, 1>>),
      Encoder.field(:bool, data.java_generate_equals_and_hash, <<160, 1>>),
      Encoder.field(:bool, data.deprecated, <<184, 1>>),
      Encoder.field(:bool, data.java_string_check_utf8, <<216, 1>>),
      Encoder.field(:bool, data.cc_enable_arenas, <<248, 1>>),
      Encoder.field(:string, data.objc_class_prefix, <<162, 2>>),
      Encoder.field(:string, data.csharp_namespace, <<170, 2>>),
      Encoder.field(:string, data.swift_prefix, <<186, 2>>),
      Encoder.field(:string, data.php_class_prefix, <<194, 2>>),
      Encoder.field(:string, data.php_namespace, <<202, 2>>),
      Encoder.field(:bool, data.php_generic_services, <<208, 2>>),
      Encoder.field(:string, data.php_metadata_namespace, <<226, 2>>),
      Encoder.field(:string, data.ruby_package, <<234, 2>>),
      Encoder.repeated_unpacked_field(:struct, data.uninterpreted_option, <<186, 62>>),
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
    Decoder.field(:string, :java_package, acc, data)
  end
  def decode(acc, <<66, data::binary>>) do
    Decoder.field(:string, :java_outer_classname, acc, data)
  end
  def decode(acc, <<72, data::binary>>) do
    Decoder.enum_field(Google.Protobuf.FileOptions.OptimizeMode, :optimize_for, acc, data)
  end
  def decode(acc, <<80, data::binary>>) do
    Decoder.field(:bool, :java_multiple_files, acc, data)
  end
  def decode(acc, <<90, data::binary>>) do
    Decoder.field(:string, :go_package, acc, data)
  end
  def decode(acc, <<128, 1, data::binary>>) do
    Decoder.field(:bool, :cc_generic_services, acc, data)
  end
  def decode(acc, <<136, 1, data::binary>>) do
    Decoder.field(:bool, :java_generic_services, acc, data)
  end
  def decode(acc, <<144, 1, data::binary>>) do
    Decoder.field(:bool, :py_generic_services, acc, data)
  end
  def decode(acc, <<160, 1, data::binary>>) do
    Decoder.field(:bool, :java_generate_equals_and_hash, acc, data)
  end
  def decode(acc, <<184, 1, data::binary>>) do
    Decoder.field(:bool, :deprecated, acc, data)
  end
  def decode(acc, <<216, 1, data::binary>>) do
    Decoder.field(:bool, :java_string_check_utf8, acc, data)
  end
  def decode(acc, <<248, 1, data::binary>>) do
    Decoder.field(:bool, :cc_enable_arenas, acc, data)
  end
  def decode(acc, <<162, 2, data::binary>>) do
    Decoder.field(:string, :objc_class_prefix, acc, data)
  end
  def decode(acc, <<170, 2, data::binary>>) do
    Decoder.field(:string, :csharp_namespace, acc, data)
  end
  def decode(acc, <<186, 2, data::binary>>) do
    Decoder.field(:string, :swift_prefix, acc, data)
  end
  def decode(acc, <<194, 2, data::binary>>) do
    Decoder.field(:string, :php_class_prefix, acc, data)
  end
  def decode(acc, <<202, 2, data::binary>>) do
    Decoder.field(:string, :php_namespace, acc, data)
  end
  def decode(acc, <<208, 2, data::binary>>) do
    Decoder.field(:bool, :php_generic_services, acc, data)
  end
  def decode(acc, <<226, 2, data::binary>>) do
    Decoder.field(:string, :php_metadata_namespace, acc, data)
  end
  def decode(acc, <<234, 2, data::binary>>) do
    Decoder.field(:string, :ruby_package, acc, data)
  end
  def decode(acc, <<186, 62, data::binary>>) do
    Decoder.struct_field(Google.Protobuf.UninterpretedOption, :uninterpreted_option, acc, data)
  end

  # failed to decode, either this is an unknown tag (which we can skip), or
  # it is a wrong type (which is an error)
  def decode(acc, data) do
    {prefix, data} = Decoder.varint(data)
    tag = bsr(prefix, 3)
    type = band(prefix, 7)
    case tag in [1,8,9,10,11,16,17,18,20,23,27,31,36,37,39,40,41,42,44,45,999] do
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
      {:uninterpreted_option, v}, acc -> Map.update(acc, :uninterpreted_option, [v], fn e -> [v | e] end)
      {k, v}, acc -> Map.put(acc, k, v)
    end)
    struct = Map.put(struct, :uninterpreted_option, Elixir.Enum.reverse(struct.uninterpreted_option))
    struct
  end
end
defmodule Google.Protobuf.MessageOptions do
  @moduledoc false
  alias Pbuf.Decoder
  import Bitwise, only: [bsr: 2, band: 2]

  @derive Jason.Encoder
  defstruct [
    message_set_wire_format: nil,
    no_standard_descriptor_accessor: nil,
    deprecated: nil,
    map_entry: nil,
    uninterpreted_option: []
  ]
  @type t :: %__MODULE__{
    message_set_wire_format: boolean,
    no_standard_descriptor_accessor: boolean,
    deprecated: boolean,
    map_entry: boolean,
    uninterpreted_option: [Google.Protobuf.UninterpretedOption.t]
  }

  @spec new(Enum.t) :: t
  def new(data \\ []) do
    struct(__MODULE__, data)
  end
  @spec encode_to_iodata!(t | map) :: iodata
  def encode_to_iodata!(data) do
    alias Elixir.Pbuf.Encoder
    [
      Encoder.field(:bool, data.message_set_wire_format, <<8>>),
      Encoder.field(:bool, data.no_standard_descriptor_accessor, <<16>>),
      Encoder.field(:bool, data.deprecated, <<24>>),
      Encoder.field(:bool, data.map_entry, <<56>>),
      Encoder.repeated_unpacked_field(:struct, data.uninterpreted_option, <<186, 62>>),
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
    Decoder.field(:bool, :message_set_wire_format, acc, data)
  end
  def decode(acc, <<16, data::binary>>) do
    Decoder.field(:bool, :no_standard_descriptor_accessor, acc, data)
  end
  def decode(acc, <<24, data::binary>>) do
    Decoder.field(:bool, :deprecated, acc, data)
  end
  def decode(acc, <<56, data::binary>>) do
    Decoder.field(:bool, :map_entry, acc, data)
  end
  def decode(acc, <<186, 62, data::binary>>) do
    Decoder.struct_field(Google.Protobuf.UninterpretedOption, :uninterpreted_option, acc, data)
  end

  # failed to decode, either this is an unknown tag (which we can skip), or
  # it is a wrong type (which is an error)
  def decode(acc, data) do
    {prefix, data} = Decoder.varint(data)
    tag = bsr(prefix, 3)
    type = band(prefix, 7)
    case tag in [1,2,3,7,999] do
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
      {:uninterpreted_option, v}, acc -> Map.update(acc, :uninterpreted_option, [v], fn e -> [v | e] end)
      {k, v}, acc -> Map.put(acc, k, v)
    end)
    struct = Map.put(struct, :uninterpreted_option, Elixir.Enum.reverse(struct.uninterpreted_option))
    struct
  end
end
defmodule Google.Protobuf.FieldOptions do
  @moduledoc false
  alias Pbuf.Decoder
  import Bitwise, only: [bsr: 2, band: 2]

  @derive Jason.Encoder
  defstruct [
    ctype: :STRING,
    packed: nil,
    deprecated: nil,
    lazy: nil,
    jstype: :JS_NORMAL,
    weak: nil,
    uninterpreted_option: []
  ]
  @type t :: %__MODULE__{
    ctype: Google.Protobuf.FieldOptions.CType.t,
    packed: boolean,
    deprecated: boolean,
    lazy: boolean,
    jstype: Google.Protobuf.FieldOptions.JSType.t,
    weak: boolean,
    uninterpreted_option: [Google.Protobuf.UninterpretedOption.t]
  }
defmodule CType do
  @moduledoc false
  @type t :: :STRING | 0 | :CORD | 1 | :STRING_PIECE | 2
  @spec to_int(t | non_neg_integer) :: integer
  def to_int(:CORD), do: 1
  def to_int(1), do: 1
  def to_int(:STRING), do: 0
  def to_int(0), do: 0
  def to_int(:STRING_PIECE), do: 2
  def to_int(2), do: 2
  def to_int(invalid) do
    raise Pbuf.Encoder.Error,
      type: __MODULE__,
      value: invalid,
      tag: nil,
      message: "#{inspect(invalid)} is not a valid enum value for #{__MODULE__}"
  end
  @spec from_int(integer) :: t
  def from_int(1), do: :CORD
  def from_int(0), do: :STRING
  def from_int(2), do: :STRING_PIECE
  def from_int(_unknown), do: :invalid
end
defmodule JSType do
  @moduledoc false
  @type t :: :JS_NORMAL | 0 | :JS_STRING | 1 | :JS_NUMBER | 2
  @spec to_int(t | non_neg_integer) :: integer
  def to_int(:JS_NORMAL), do: 0
  def to_int(0), do: 0
  def to_int(:JS_NUMBER), do: 2
  def to_int(2), do: 2
  def to_int(:JS_STRING), do: 1
  def to_int(1), do: 1
  def to_int(invalid) do
    raise Pbuf.Encoder.Error,
      type: __MODULE__,
      value: invalid,
      tag: nil,
      message: "#{inspect(invalid)} is not a valid enum value for #{__MODULE__}"
  end
  @spec from_int(integer) :: t
  def from_int(0), do: :JS_NORMAL
  def from_int(2), do: :JS_NUMBER
  def from_int(1), do: :JS_STRING
  def from_int(_unknown), do: :invalid
end
  @spec new(Enum.t) :: t
  def new(data \\ []) do
    struct(__MODULE__, data)
  end
  @spec encode_to_iodata!(t | map) :: iodata
  def encode_to_iodata!(data) do
    alias Elixir.Pbuf.Encoder
    [
      Encoder.enum_field(Google.Protobuf.FieldOptions.CType, data.ctype, <<8>>),
      Encoder.field(:bool, data.packed, <<16>>),
      Encoder.field(:bool, data.deprecated, <<24>>),
      Encoder.field(:bool, data.lazy, <<40>>),
      Encoder.enum_field(Google.Protobuf.FieldOptions.JSType, data.jstype, <<48>>),
      Encoder.field(:bool, data.weak, <<80>>),
      Encoder.repeated_unpacked_field(:struct, data.uninterpreted_option, <<186, 62>>),
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
    Decoder.enum_field(Google.Protobuf.FieldOptions.CType, :ctype, acc, data)
  end
  def decode(acc, <<16, data::binary>>) do
    Decoder.field(:bool, :packed, acc, data)
  end
  def decode(acc, <<24, data::binary>>) do
    Decoder.field(:bool, :deprecated, acc, data)
  end
  def decode(acc, <<40, data::binary>>) do
    Decoder.field(:bool, :lazy, acc, data)
  end
  def decode(acc, <<48, data::binary>>) do
    Decoder.enum_field(Google.Protobuf.FieldOptions.JSType, :jstype, acc, data)
  end
  def decode(acc, <<80, data::binary>>) do
    Decoder.field(:bool, :weak, acc, data)
  end
  def decode(acc, <<186, 62, data::binary>>) do
    Decoder.struct_field(Google.Protobuf.UninterpretedOption, :uninterpreted_option, acc, data)
  end

  # failed to decode, either this is an unknown tag (which we can skip), or
  # it is a wrong type (which is an error)
  def decode(acc, data) do
    {prefix, data} = Decoder.varint(data)
    tag = bsr(prefix, 3)
    type = band(prefix, 7)
    case tag in [1,2,3,5,6,10,999] do
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
      {:uninterpreted_option, v}, acc -> Map.update(acc, :uninterpreted_option, [v], fn e -> [v | e] end)
      {k, v}, acc -> Map.put(acc, k, v)
    end)
    struct = Map.put(struct, :uninterpreted_option, Elixir.Enum.reverse(struct.uninterpreted_option))
    struct
  end
end
defmodule Google.Protobuf.OneofOptions do
  @moduledoc false
  alias Pbuf.Decoder
  import Bitwise, only: [bsr: 2, band: 2]

  @derive Jason.Encoder
  defstruct [
    uninterpreted_option: []
  ]
  @type t :: %__MODULE__{
    uninterpreted_option: [Google.Protobuf.UninterpretedOption.t]
  }

  @spec new(Enum.t) :: t
  def new(data \\ []) do
    struct(__MODULE__, data)
  end
  @spec encode_to_iodata!(t | map) :: iodata
  def encode_to_iodata!(data) do
    alias Elixir.Pbuf.Encoder
    [
      Encoder.repeated_unpacked_field(:struct, data.uninterpreted_option, <<186, 62>>),
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
  def decode(acc, <<186, 62, data::binary>>) do
    Decoder.struct_field(Google.Protobuf.UninterpretedOption, :uninterpreted_option, acc, data)
  end

  # failed to decode, either this is an unknown tag (which we can skip), or
  # it is a wrong type (which is an error)
  def decode(acc, data) do
    {prefix, data} = Decoder.varint(data)
    tag = bsr(prefix, 3)
    type = band(prefix, 7)
    case tag in [999] do
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
      {:uninterpreted_option, v}, acc -> Map.update(acc, :uninterpreted_option, [v], fn e -> [v | e] end)
      {k, v}, acc -> Map.put(acc, k, v)
    end)
    struct = Map.put(struct, :uninterpreted_option, Elixir.Enum.reverse(struct.uninterpreted_option))
    struct
  end
end
defmodule Google.Protobuf.EnumOptions do
  @moduledoc false
  alias Pbuf.Decoder
  import Bitwise, only: [bsr: 2, band: 2]

  @derive Jason.Encoder
  defstruct [
    allow_alias: nil,
    deprecated: nil,
    uninterpreted_option: []
  ]
  @type t :: %__MODULE__{
    allow_alias: boolean,
    deprecated: boolean,
    uninterpreted_option: [Google.Protobuf.UninterpretedOption.t]
  }

  @spec new(Enum.t) :: t
  def new(data \\ []) do
    struct(__MODULE__, data)
  end
  @spec encode_to_iodata!(t | map) :: iodata
  def encode_to_iodata!(data) do
    alias Elixir.Pbuf.Encoder
    [
      Encoder.field(:bool, data.allow_alias, <<16>>),
      Encoder.field(:bool, data.deprecated, <<24>>),
      Encoder.repeated_unpacked_field(:struct, data.uninterpreted_option, <<186, 62>>),
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
  def decode(acc, <<16, data::binary>>) do
    Decoder.field(:bool, :allow_alias, acc, data)
  end
  def decode(acc, <<24, data::binary>>) do
    Decoder.field(:bool, :deprecated, acc, data)
  end
  def decode(acc, <<186, 62, data::binary>>) do
    Decoder.struct_field(Google.Protobuf.UninterpretedOption, :uninterpreted_option, acc, data)
  end

  # failed to decode, either this is an unknown tag (which we can skip), or
  # it is a wrong type (which is an error)
  def decode(acc, data) do
    {prefix, data} = Decoder.varint(data)
    tag = bsr(prefix, 3)
    type = band(prefix, 7)
    case tag in [2,3,999] do
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
      {:uninterpreted_option, v}, acc -> Map.update(acc, :uninterpreted_option, [v], fn e -> [v | e] end)
      {k, v}, acc -> Map.put(acc, k, v)
    end)
    struct = Map.put(struct, :uninterpreted_option, Elixir.Enum.reverse(struct.uninterpreted_option))
    struct
  end
end
defmodule Google.Protobuf.EnumValueOptions do
  @moduledoc false
  alias Pbuf.Decoder
  import Bitwise, only: [bsr: 2, band: 2]

  @derive Jason.Encoder
  defstruct [
    deprecated: nil,
    uninterpreted_option: []
  ]
  @type t :: %__MODULE__{
    deprecated: boolean,
    uninterpreted_option: [Google.Protobuf.UninterpretedOption.t]
  }

  @spec new(Enum.t) :: t
  def new(data \\ []) do
    struct(__MODULE__, data)
  end
  @spec encode_to_iodata!(t | map) :: iodata
  def encode_to_iodata!(data) do
    alias Elixir.Pbuf.Encoder
    [
      Encoder.field(:bool, data.deprecated, <<8>>),
      Encoder.repeated_unpacked_field(:struct, data.uninterpreted_option, <<186, 62>>),
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
    Decoder.field(:bool, :deprecated, acc, data)
  end
  def decode(acc, <<186, 62, data::binary>>) do
    Decoder.struct_field(Google.Protobuf.UninterpretedOption, :uninterpreted_option, acc, data)
  end

  # failed to decode, either this is an unknown tag (which we can skip), or
  # it is a wrong type (which is an error)
  def decode(acc, data) do
    {prefix, data} = Decoder.varint(data)
    tag = bsr(prefix, 3)
    type = band(prefix, 7)
    case tag in [1,999] do
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
      {:uninterpreted_option, v}, acc -> Map.update(acc, :uninterpreted_option, [v], fn e -> [v | e] end)
      {k, v}, acc -> Map.put(acc, k, v)
    end)
    struct = Map.put(struct, :uninterpreted_option, Elixir.Enum.reverse(struct.uninterpreted_option))
    struct
  end
end
defmodule Google.Protobuf.ServiceOptions do
  @moduledoc false
  alias Pbuf.Decoder
  import Bitwise, only: [bsr: 2, band: 2]

  @derive Jason.Encoder
  defstruct [
    deprecated: nil,
    uninterpreted_option: []
  ]
  @type t :: %__MODULE__{
    deprecated: boolean,
    uninterpreted_option: [Google.Protobuf.UninterpretedOption.t]
  }

  @spec new(Enum.t) :: t
  def new(data \\ []) do
    struct(__MODULE__, data)
  end
  @spec encode_to_iodata!(t | map) :: iodata
  def encode_to_iodata!(data) do
    alias Elixir.Pbuf.Encoder
    [
      Encoder.field(:bool, data.deprecated, <<136, 2>>),
      Encoder.repeated_unpacked_field(:struct, data.uninterpreted_option, <<186, 62>>),
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
  def decode(acc, <<136, 2, data::binary>>) do
    Decoder.field(:bool, :deprecated, acc, data)
  end
  def decode(acc, <<186, 62, data::binary>>) do
    Decoder.struct_field(Google.Protobuf.UninterpretedOption, :uninterpreted_option, acc, data)
  end

  # failed to decode, either this is an unknown tag (which we can skip), or
  # it is a wrong type (which is an error)
  def decode(acc, data) do
    {prefix, data} = Decoder.varint(data)
    tag = bsr(prefix, 3)
    type = band(prefix, 7)
    case tag in [33,999] do
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
      {:uninterpreted_option, v}, acc -> Map.update(acc, :uninterpreted_option, [v], fn e -> [v | e] end)
      {k, v}, acc -> Map.put(acc, k, v)
    end)
    struct = Map.put(struct, :uninterpreted_option, Elixir.Enum.reverse(struct.uninterpreted_option))
    struct
  end
end
defmodule Google.Protobuf.MethodOptions do
  @moduledoc false
  alias Pbuf.Decoder
  import Bitwise, only: [bsr: 2, band: 2]

  @derive Jason.Encoder
  defstruct [
    deprecated: nil,
    idempotency_level: :IDEMPOTENCY_UNKNOWN,
    uninterpreted_option: []
  ]
  @type t :: %__MODULE__{
    deprecated: boolean,
    idempotency_level: Google.Protobuf.MethodOptions.IdempotencyLevel.t,
    uninterpreted_option: [Google.Protobuf.UninterpretedOption.t]
  }
defmodule IdempotencyLevel do
  @moduledoc false
  @type t :: :IDEMPOTENCY_UNKNOWN | 0 | :NO_SIDE_EFFECTS | 1 | :IDEMPOTENT | 2
  @spec to_int(t | non_neg_integer) :: integer
  def to_int(:IDEMPOTENCY_UNKNOWN), do: 0
  def to_int(0), do: 0
  def to_int(:IDEMPOTENT), do: 2
  def to_int(2), do: 2
  def to_int(:NO_SIDE_EFFECTS), do: 1
  def to_int(1), do: 1
  def to_int(invalid) do
    raise Pbuf.Encoder.Error,
      type: __MODULE__,
      value: invalid,
      tag: nil,
      message: "#{inspect(invalid)} is not a valid enum value for #{__MODULE__}"
  end
  @spec from_int(integer) :: t
  def from_int(0), do: :IDEMPOTENCY_UNKNOWN
  def from_int(2), do: :IDEMPOTENT
  def from_int(1), do: :NO_SIDE_EFFECTS
  def from_int(_unknown), do: :invalid
end
  @spec new(Enum.t) :: t
  def new(data \\ []) do
    struct(__MODULE__, data)
  end
  @spec encode_to_iodata!(t | map) :: iodata
  def encode_to_iodata!(data) do
    alias Elixir.Pbuf.Encoder
    [
      Encoder.field(:bool, data.deprecated, <<136, 2>>),
      Encoder.enum_field(Google.Protobuf.MethodOptions.IdempotencyLevel, data.idempotency_level, <<144, 2>>),
      Encoder.repeated_unpacked_field(:struct, data.uninterpreted_option, <<186, 62>>),
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
  def decode(acc, <<136, 2, data::binary>>) do
    Decoder.field(:bool, :deprecated, acc, data)
  end
  def decode(acc, <<144, 2, data::binary>>) do
    Decoder.enum_field(Google.Protobuf.MethodOptions.IdempotencyLevel, :idempotency_level, acc, data)
  end
  def decode(acc, <<186, 62, data::binary>>) do
    Decoder.struct_field(Google.Protobuf.UninterpretedOption, :uninterpreted_option, acc, data)
  end

  # failed to decode, either this is an unknown tag (which we can skip), or
  # it is a wrong type (which is an error)
  def decode(acc, data) do
    {prefix, data} = Decoder.varint(data)
    tag = bsr(prefix, 3)
    type = band(prefix, 7)
    case tag in [33,34,999] do
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
      {:uninterpreted_option, v}, acc -> Map.update(acc, :uninterpreted_option, [v], fn e -> [v | e] end)
      {k, v}, acc -> Map.put(acc, k, v)
    end)
    struct = Map.put(struct, :uninterpreted_option, Elixir.Enum.reverse(struct.uninterpreted_option))
    struct
  end
end
defmodule Google.Protobuf.UninterpretedOption do
  @moduledoc false
  alias Pbuf.Decoder
  import Bitwise, only: [bsr: 2, band: 2]

  @derive Jason.Encoder
  defstruct [
    name: [],
    identifier_value: nil,
    positive_int_value: nil,
    negative_int_value: nil,
    double_value: nil,
    string_value: nil,
    aggregate_value: nil
  ]
  @type t :: %__MODULE__{
    name: [Google.Protobuf.UninterpretedOption.NamePart.t],
    identifier_value: String.t,
    positive_int_value: non_neg_integer,
    negative_int_value: integer,
    double_value: number,
    string_value: binary,
    aggregate_value: String.t
  }

  @spec new(Enum.t) :: t
  def new(data \\ []) do
    struct(__MODULE__, data)
  end
  @spec encode_to_iodata!(t | map) :: iodata
  def encode_to_iodata!(data) do
    alias Elixir.Pbuf.Encoder
    [
      Encoder.repeated_unpacked_field(:struct, data.name, <<18>>),
      Encoder.field(:string, data.identifier_value, <<26>>),
      Encoder.field(:uint64, data.positive_int_value, <<32>>),
      Encoder.field(:int64, data.negative_int_value, <<40>>),
      Encoder.field(:double, data.double_value, <<49>>),
      Encoder.field(:bytes, data.string_value, <<58>>),
      Encoder.field(:string, data.aggregate_value, <<66>>),
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
  def decode(acc, <<18, data::binary>>) do
    Decoder.struct_field(Google.Protobuf.UninterpretedOption.NamePart, :name, acc, data)
  end
  def decode(acc, <<26, data::binary>>) do
    Decoder.field(:string, :identifier_value, acc, data)
  end
  def decode(acc, <<32, data::binary>>) do
    Decoder.field(:uint64, :positive_int_value, acc, data)
  end
  def decode(acc, <<40, data::binary>>) do
    Decoder.field(:int64, :negative_int_value, acc, data)
  end
  def decode(acc, <<49, data::binary>>) do
    Decoder.field(:double, :double_value, acc, data)
  end
  def decode(acc, <<58, data::binary>>) do
    Decoder.field(:bytes, :string_value, acc, data)
  end
  def decode(acc, <<66, data::binary>>) do
    Decoder.field(:string, :aggregate_value, acc, data)
  end

  # failed to decode, either this is an unknown tag (which we can skip), or
  # it is a wrong type (which is an error)
  def decode(acc, data) do
    {prefix, data} = Decoder.varint(data)
    tag = bsr(prefix, 3)
    type = band(prefix, 7)
    case tag in [2,3,4,5,6,7,8] do
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
      {:name, v}, acc -> Map.update(acc, :name, [v], fn e -> [v | e] end)
      {k, v}, acc -> Map.put(acc, k, v)
    end)
    struct = Map.put(struct, :name, Elixir.Enum.reverse(struct.name))
    struct
  end
end
defmodule Google.Protobuf.UninterpretedOption.NamePart do
  @moduledoc false
  alias Pbuf.Decoder
  import Bitwise, only: [bsr: 2, band: 2]

  @derive Jason.Encoder
  defstruct [
    name_part: nil,
    is_extension: nil
  ]
  @type t :: %__MODULE__{
    name_part: String.t,
    is_extension: boolean
  }

  @spec new(Enum.t) :: t
  def new(data \\ []) do
    struct(__MODULE__, data)
  end
  @spec encode_to_iodata!(t | map) :: iodata
  def encode_to_iodata!(data) do
    alias Elixir.Pbuf.Encoder
    [
      Encoder.field(:string, data.name_part, <<10>>),
      Encoder.field(:bool, data.is_extension, <<16>>),
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
    Decoder.field(:string, :name_part, acc, data)
  end
  def decode(acc, <<16, data::binary>>) do
    Decoder.field(:bool, :is_extension, acc, data)
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
defmodule Google.Protobuf.SourceCodeInfo do
  @moduledoc false
  alias Pbuf.Decoder
  import Bitwise, only: [bsr: 2, band: 2]

  @derive Jason.Encoder
  defstruct [
    location: []
  ]
  @type t :: %__MODULE__{
    location: [Google.Protobuf.SourceCodeInfo.Location.t]
  }

  @spec new(Enum.t) :: t
  def new(data \\ []) do
    struct(__MODULE__, data)
  end
  @spec encode_to_iodata!(t | map) :: iodata
  def encode_to_iodata!(data) do
    alias Elixir.Pbuf.Encoder
    [
      Encoder.repeated_unpacked_field(:struct, data.location, <<10>>),
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
    Decoder.struct_field(Google.Protobuf.SourceCodeInfo.Location, :location, acc, data)
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
      {:location, v}, acc -> Map.update(acc, :location, [v], fn e -> [v | e] end)
      {k, v}, acc -> Map.put(acc, k, v)
    end)
    struct = Map.put(struct, :location, Elixir.Enum.reverse(struct.location))
    struct
  end
end
defmodule Google.Protobuf.SourceCodeInfo.Location do
  @moduledoc false
  alias Pbuf.Decoder
  import Bitwise, only: [bsr: 2, band: 2]

  @derive Jason.Encoder
  defstruct [
    path: [],
    span: [],
    leading_comments: nil,
    trailing_comments: nil,
    leading_detached_comments: []
  ]
  @type t :: %__MODULE__{
    path: [integer],
    span: [integer],
    leading_comments: String.t,
    trailing_comments: String.t,
    leading_detached_comments: [String.t]
  }

  @spec new(Enum.t) :: t
  def new(data \\ []) do
    struct(__MODULE__, data)
  end
  @spec encode_to_iodata!(t | map) :: iodata
  def encode_to_iodata!(data) do
    alias Elixir.Pbuf.Encoder
    [
      Encoder.repeated_field(:int32, data.path, <<10>>),
      Encoder.repeated_field(:int32, data.span, <<18>>),
      Encoder.field(:string, data.leading_comments, <<26>>),
      Encoder.field(:string, data.trailing_comments, <<34>>),
      Encoder.repeated_unpacked_field(:string, data.leading_detached_comments, <<50>>),
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
    Decoder.repeated_field(:int32, :path, acc, data)
  end
  def decode(acc, <<18, data::binary>>) do
    Decoder.repeated_field(:int32, :span, acc, data)
  end
  def decode(acc, <<26, data::binary>>) do
    Decoder.field(:string, :leading_comments, acc, data)
  end
  def decode(acc, <<34, data::binary>>) do
    Decoder.field(:string, :trailing_comments, acc, data)
  end
  def decode(acc, <<50, data::binary>>) do
    Decoder.field(:string, :leading_detached_comments, acc, data)
  end

  # failed to decode, either this is an unknown tag (which we can skip), or
  # it is a wrong type (which is an error)
  def decode(acc, data) do
    {prefix, data} = Decoder.varint(data)
    tag = bsr(prefix, 3)
    type = band(prefix, 7)
    case tag in [1,2,3,4,6] do
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
      {:leading_detached_comments, v}, acc -> Map.update(acc, :leading_detached_comments, [v], fn e -> [v | e] end)
      {k, v}, acc -> Map.put(acc, k, v)
    end)
    struct = Map.put(struct, :leading_detached_comments, Elixir.Enum.reverse(struct.leading_detached_comments))
    struct
  end
end
defmodule Google.Protobuf.GeneratedCodeInfo do
  @moduledoc false
  alias Pbuf.Decoder
  import Bitwise, only: [bsr: 2, band: 2]

  @derive Jason.Encoder
  defstruct [
    annotation: []
  ]
  @type t :: %__MODULE__{
    annotation: [Google.Protobuf.GeneratedCodeInfo.Annotation.t]
  }

  @spec new(Enum.t) :: t
  def new(data \\ []) do
    struct(__MODULE__, data)
  end
  @spec encode_to_iodata!(t | map) :: iodata
  def encode_to_iodata!(data) do
    alias Elixir.Pbuf.Encoder
    [
      Encoder.repeated_unpacked_field(:struct, data.annotation, <<10>>),
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
    Decoder.struct_field(Google.Protobuf.GeneratedCodeInfo.Annotation, :annotation, acc, data)
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
      {:annotation, v}, acc -> Map.update(acc, :annotation, [v], fn e -> [v | e] end)
      {k, v}, acc -> Map.put(acc, k, v)
    end)
    struct = Map.put(struct, :annotation, Elixir.Enum.reverse(struct.annotation))
    struct
  end
end
defmodule Google.Protobuf.GeneratedCodeInfo.Annotation do
  @moduledoc false
  alias Pbuf.Decoder
  import Bitwise, only: [bsr: 2, band: 2]

  @derive Jason.Encoder
  defstruct [
    path: [],
    source_file: nil,
    begin: nil,
    end: nil
  ]
  @type t :: %__MODULE__{
    path: [integer],
    source_file: String.t,
    begin: integer,
    end: integer
  }

  @spec new(Enum.t) :: t
  def new(data \\ []) do
    struct(__MODULE__, data)
  end
  @spec encode_to_iodata!(t | map) :: iodata
  def encode_to_iodata!(data) do
    alias Elixir.Pbuf.Encoder
    [
      Encoder.repeated_field(:int32, data.path, <<10>>),
      Encoder.field(:string, data.source_file, <<18>>),
      Encoder.field(:int32, data.begin, <<24>>),
      Encoder.field(:int32, data.end, <<32>>),
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
    Decoder.repeated_field(:int32, :path, acc, data)
  end
  def decode(acc, <<18, data::binary>>) do
    Decoder.field(:string, :source_file, acc, data)
  end
  def decode(acc, <<24, data::binary>>) do
    Decoder.field(:int32, :begin, acc, data)
  end
  def decode(acc, <<32, data::binary>>) do
    Decoder.field(:int32, :end, acc, data)
  end

  # failed to decode, either this is an unknown tag (which we can skip), or
  # it is a wrong type (which is an error)
  def decode(acc, data) do
    {prefix, data} = Decoder.varint(data)
    tag = bsr(prefix, 3)
    type = band(prefix, 7)
    case tag in [1,2,3,4] do
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
