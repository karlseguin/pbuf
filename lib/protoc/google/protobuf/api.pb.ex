defmodule Google.Protobuf.Api do
  @moduledoc false
  alias Pbuf.{Decoder, Encoder}
  import Bitwise, only: [bsr: 2, band: 2]

  alias __MODULE__

  defstruct [
    __pbuf__: true,
    name: "",
    methods: [],
    options: [],
    version: "",
    source_context: nil,
    mixins: [],
    syntax: 0
  ]

  @type t :: %Api{
    name: String.t,
    methods: [Google.Protobuf.Method.t],
    options: [Google.Protobuf.Option.t],
    version: String.t,
    source_context: Google.Protobuf.SourceContext.t,
    mixins: [Google.Protobuf.Mixin.t],
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
      Encoder.repeated_field(:struct, data.methods, <<18>>),
      Encoder.repeated_field(:struct, data.options, <<26>>),
      Encoder.field(:string, data.version, <<34>>),
      Encoder.field(:struct, data.source_context, <<42>>),
      Encoder.repeated_field(:struct, data.mixins, <<50>>),
      Encoder.enum_field(Google.Protobuf.Syntax, data.syntax, <<56>>),
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
    Decoder.struct_field(Google.Protobuf.Method, :methods, acc, data)
  end
  
  def decode(acc, <<26, data::binary>>) do
    Decoder.struct_field(Google.Protobuf.Option, :options, acc, data)
  end
  
  def decode(acc, <<34, data::binary>>) do
    Decoder.field(:string, :version, acc, data)
  end
  
  def decode(acc, <<42, data::binary>>) do
    Decoder.struct_field(Google.Protobuf.SourceContext, :source_context, acc, data)
  end
  
  def decode(acc, <<50, data::binary>>) do
    Decoder.struct_field(Google.Protobuf.Mixin, :mixins, acc, data)
  end
  
  def decode(acc, <<56, data::binary>>) do
    Decoder.enum_field(Google.Protobuf.Syntax, :syntax, acc, data)
  end


  # failed to decode, either this is an unknown tag (which we can skip), or
  # it's a wrong type (which is an error)
  def decode(acc, data) do
    {prefix, data} = Decoder.varint(data)
    tag = bsr(prefix, 3)
    type = band(prefix, 7)

    case tag in [1,2,3,4,5,6,7] do
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
      
      {:methods, v}, acc -> Map.update(acc, :methods, [v], fn e -> [v | e] end)

      {:options, v}, acc -> Map.update(acc, :options, [v], fn e -> [v | e] end)

      {:mixins, v}, acc -> Map.update(acc, :mixins, [v], fn e -> [v | e] end)
      {k, v}, acc -> Map.put(acc, k, v)
    end)

    struct = Map.put(struct, :methods, Elixir.Enum.reverse(struct.methods))
    struct = Map.put(struct, :options, Elixir.Enum.reverse(struct.options))
    struct = Map.put(struct, :mixins, Elixir.Enum.reverse(struct.mixins))
    struct
  end
end
defmodule Google.Protobuf.Method do
  @moduledoc false
  alias Pbuf.{Decoder, Encoder}
  import Bitwise, only: [bsr: 2, band: 2]

  alias __MODULE__

  defstruct [
    __pbuf__: true,
    name: "",
    request_type_url: "",
    request_streaming: false,
    response_type_url: "",
    response_streaming: false,
    options: [],
    syntax: 0
  ]

  @type t :: %Method{
    name: String.t,
    request_type_url: String.t,
    request_streaming: boolean,
    response_type_url: String.t,
    response_streaming: boolean,
    options: [Google.Protobuf.Option.t],
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
      Encoder.field(:string, data.request_type_url, <<18>>),
      Encoder.field(:bool, data.request_streaming, <<24>>),
      Encoder.field(:string, data.response_type_url, <<34>>),
      Encoder.field(:bool, data.response_streaming, <<40>>),
      Encoder.repeated_field(:struct, data.options, <<50>>),
      Encoder.enum_field(Google.Protobuf.Syntax, data.syntax, <<56>>),
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
    Decoder.field(:string, :request_type_url, acc, data)
  end
  
  def decode(acc, <<24, data::binary>>) do
    Decoder.field(:bool, :request_streaming, acc, data)
  end
  
  def decode(acc, <<34, data::binary>>) do
    Decoder.field(:string, :response_type_url, acc, data)
  end
  
  def decode(acc, <<40, data::binary>>) do
    Decoder.field(:bool, :response_streaming, acc, data)
  end
  
  def decode(acc, <<50, data::binary>>) do
    Decoder.struct_field(Google.Protobuf.Option, :options, acc, data)
  end
  
  def decode(acc, <<56, data::binary>>) do
    Decoder.enum_field(Google.Protobuf.Syntax, :syntax, acc, data)
  end


  # failed to decode, either this is an unknown tag (which we can skip), or
  # it's a wrong type (which is an error)
  def decode(acc, data) do
    {prefix, data} = Decoder.varint(data)
    tag = bsr(prefix, 3)
    type = band(prefix, 7)

    case tag in [1,2,3,4,5,6,7] do
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
defmodule Google.Protobuf.Mixin do
  @moduledoc false
  alias Pbuf.{Decoder, Encoder}
  import Bitwise, only: [bsr: 2, band: 2]

  alias __MODULE__

  defstruct [
    __pbuf__: true,
    name: "",
    root: ""
  ]

  @type t :: %Mixin{
    name: String.t,
    root: String.t
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
      Encoder.field(:string, data.root, <<18>>),
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
    Decoder.field(:string, :root, acc, data)
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
