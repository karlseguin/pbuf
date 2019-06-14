defmodule Google.Protobuf.Compiler.Version do
  @moduledoc false
  alias Pbuf.Decoder
  import Bitwise, only: [bsr: 2, band: 2]

  @derive Jason.Encoder
  defstruct [
    major: nil,
    minor: nil,
    patch: nil,
    suffix: nil
  ]
  @type t :: %__MODULE__{
    major: integer,
    minor: integer,
    patch: integer,
    suffix: String.t
  }

  @spec new(Enum.t) :: t
  def new(data) do
    struct(__MODULE__, data)
  end
  @spec encode_to_iodata!(t | map) :: iodata
  def encode_to_iodata!(data) do
    alias Elixir.Pbuf.Encoder
    [
      Encoder.field(:int32, data.major, <<8>>),
      Encoder.field(:int32, data.minor, <<16>>),
      Encoder.field(:int32, data.patch, <<24>>),
      Encoder.field(:string, data.suffix, <<34>>),
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
    Decoder.field(:int32, :major, acc, data)
  end
  
  def decode(acc, <<16, data::binary>>) do
    Decoder.field(:int32, :minor, acc, data)
  end
  
  def decode(acc, <<24, data::binary>>) do
    Decoder.field(:int32, :patch, acc, data)
  end
  
  def decode(acc, <<34, data::binary>>) do
    Decoder.field(:string, :suffix, acc, data)
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
defmodule Google.Protobuf.Compiler.CodeGeneratorRequest do
  @moduledoc false
  alias Pbuf.Decoder
  import Bitwise, only: [bsr: 2, band: 2]

  @derive Jason.Encoder
  defstruct [
    file_to_generate: [],
    parameter: nil,
    compiler_version: nil,
    proto_file: []
  ]
  @type t :: %__MODULE__{
    file_to_generate: [String.t],
    parameter: String.t,
    compiler_version: Google.Protobuf.Compiler.Version.t,
    proto_file: [Google.Protobuf.FileDescriptorProto.t]
  }

  @spec new(Enum.t) :: t
  def new(data) do
    struct(__MODULE__, data)
  end
  @spec encode_to_iodata!(t | map) :: iodata
  def encode_to_iodata!(data) do
    alias Elixir.Pbuf.Encoder
    [
      Encoder.repeated_unpacked_field(:string, data.file_to_generate, <<10>>),
      Encoder.field(:string, data.parameter, <<18>>),
      Encoder.field(:struct, data.compiler_version, <<26>>),
      Encoder.repeated_unpacked_field(:struct, data.proto_file, <<122>>),
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
    Decoder.field(:string, :file_to_generate, acc, data)
  end
  
  def decode(acc, <<18, data::binary>>) do
    Decoder.field(:string, :parameter, acc, data)
  end
  
  def decode(acc, <<26, data::binary>>) do
    Decoder.struct_field(Google.Protobuf.Compiler.Version, :compiler_version, acc, data)
  end
  
  def decode(acc, <<122, data::binary>>) do
    Decoder.struct_field(Google.Protobuf.FileDescriptorProto, :proto_file, acc, data)
  end

  # failed to decode, either this is an unknown tag (which we can skip), or
  # it is a wrong type (which is an error)
  def decode(acc, data) do
    {prefix, data} = Decoder.varint(data)
    tag = bsr(prefix, 3)
    type = band(prefix, 7)
    case tag in [1,2,3,15] do
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
      
      {:proto_file, v}, acc -> Map.update(acc, :proto_file, [v], fn e -> [v | e] end)
      {:file_to_generate, v}, acc -> Map.update(acc, :file_to_generate, [v], fn e -> [v | e] end)
            {k, v}, acc -> Map.put(acc, k, v)
    end)
    struct = Map.put(struct, :proto_file, Elixir.Enum.reverse(struct.proto_file))
    struct = Map.put(struct, :file_to_generate, Elixir.Enum.reverse(struct.file_to_generate))
    struct
  end
end
defmodule Google.Protobuf.Compiler.CodeGeneratorResponse do
  @moduledoc false
  alias Pbuf.Decoder
  import Bitwise, only: [bsr: 2, band: 2]

  @derive Jason.Encoder
  defstruct [
    error: nil,
    file: []
  ]
  @type t :: %__MODULE__{
    error: String.t,
    file: [Google.Protobuf.Compiler.CodeGeneratorResponse.File.t]
  }

  @spec new(Enum.t) :: t
  def new(data) do
    struct(__MODULE__, data)
  end
  @spec encode_to_iodata!(t | map) :: iodata
  def encode_to_iodata!(data) do
    alias Elixir.Pbuf.Encoder
    [
      Encoder.field(:string, data.error, <<10>>),
      Encoder.repeated_unpacked_field(:struct, data.file, <<122>>),
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
    Decoder.field(:string, :error, acc, data)
  end
  
  def decode(acc, <<122, data::binary>>) do
    Decoder.struct_field(Google.Protobuf.Compiler.CodeGeneratorResponse.File, :file, acc, data)
  end

  # failed to decode, either this is an unknown tag (which we can skip), or
  # it is a wrong type (which is an error)
  def decode(acc, data) do
    {prefix, data} = Decoder.varint(data)
    tag = bsr(prefix, 3)
    type = band(prefix, 7)
    case tag in [1,15] do
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
defmodule Google.Protobuf.Compiler.CodeGeneratorResponse.File do
  @moduledoc false
  alias Pbuf.Decoder
  import Bitwise, only: [bsr: 2, band: 2]

  @derive Jason.Encoder
  defstruct [
    name: nil,
    insertion_point: nil,
    content: nil
  ]
  @type t :: %__MODULE__{
    name: String.t,
    insertion_point: String.t,
    content: String.t
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
      Encoder.field(:string, data.insertion_point, <<18>>),
      Encoder.field(:string, data.content, <<122>>),
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
    Decoder.field(:string, :insertion_point, acc, data)
  end
  
  def decode(acc, <<122, data::binary>>) do
    Decoder.field(:string, :content, acc, data)
  end

  # failed to decode, either this is an unknown tag (which we can skip), or
  # it is a wrong type (which is an error)
  def decode(acc, data) do
    {prefix, data} = Decoder.varint(data)
    tag = bsr(prefix, 3)
    type = band(prefix, 7)
    case tag in [1,2,15] do
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
