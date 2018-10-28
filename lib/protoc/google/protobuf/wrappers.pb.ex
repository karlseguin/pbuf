defmodule Google.Protobuf.DoubleValue do
  @moduledoc false
  alias Pbuf.{Decoder, Encoder}
  import Bitwise, only: [bsr: 2, band: 2]

  alias __MODULE__

  defstruct [
    __pbuf__: true,
    value: 0.0
  ]

  @type t :: %DoubleValue{
    value: number
  }


  @spec new(Enum.t) :: t
  def new(data) do
    struct(__MODULE__, data)
  end

  @spec encode_to_iodata!(t | map) :: iodata
  def encode_to_iodata!(data) do
    alias Elixir.Pbuf.Encoder
    [
      Encoder.field(:double, data.value, <<9>>),
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
  
  def decode(acc, <<9, data::binary>>) do
    Decoder.field(:double, :value, acc, data)
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
defmodule Google.Protobuf.FloatValue do
  @moduledoc false
  alias Pbuf.{Decoder, Encoder}
  import Bitwise, only: [bsr: 2, band: 2]

  alias __MODULE__

  defstruct [
    __pbuf__: true,
    value: 0.0
  ]

  @type t :: %FloatValue{
    value: number
  }


  @spec new(Enum.t) :: t
  def new(data) do
    struct(__MODULE__, data)
  end

  @spec encode_to_iodata!(t | map) :: iodata
  def encode_to_iodata!(data) do
    alias Elixir.Pbuf.Encoder
    [
      Encoder.field(:float, data.value, <<13>>),
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
  
  def decode(acc, <<13, data::binary>>) do
    Decoder.field(:float, :value, acc, data)
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
defmodule Google.Protobuf.Int64Value do
  @moduledoc false
  alias Pbuf.{Decoder, Encoder}
  import Bitwise, only: [bsr: 2, band: 2]

  alias __MODULE__

  defstruct [
    __pbuf__: true,
    value: 0
  ]

  @type t :: %Int64Value{
    value: integer
  }


  @spec new(Enum.t) :: t
  def new(data) do
    struct(__MODULE__, data)
  end

  @spec encode_to_iodata!(t | map) :: iodata
  def encode_to_iodata!(data) do
    alias Elixir.Pbuf.Encoder
    [
      Encoder.field(:int64, data.value, <<8>>),
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
    Decoder.field(:int64, :value, acc, data)
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
defmodule Google.Protobuf.UInt64Value do
  @moduledoc false
  alias Pbuf.{Decoder, Encoder}
  import Bitwise, only: [bsr: 2, band: 2]

  alias __MODULE__

  defstruct [
    __pbuf__: true,
    value: 0
  ]

  @type t :: %UInt64Value{
    value: non_neg_integer
  }


  @spec new(Enum.t) :: t
  def new(data) do
    struct(__MODULE__, data)
  end

  @spec encode_to_iodata!(t | map) :: iodata
  def encode_to_iodata!(data) do
    alias Elixir.Pbuf.Encoder
    [
      Encoder.field(:uint64, data.value, <<8>>),
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
    Decoder.field(:uint64, :value, acc, data)
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
defmodule Google.Protobuf.Int32Value do
  @moduledoc false
  alias Pbuf.{Decoder, Encoder}
  import Bitwise, only: [bsr: 2, band: 2]

  alias __MODULE__

  defstruct [
    __pbuf__: true,
    value: 0
  ]

  @type t :: %Int32Value{
    value: integer
  }


  @spec new(Enum.t) :: t
  def new(data) do
    struct(__MODULE__, data)
  end

  @spec encode_to_iodata!(t | map) :: iodata
  def encode_to_iodata!(data) do
    alias Elixir.Pbuf.Encoder
    [
      Encoder.field(:int32, data.value, <<8>>),
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
    Decoder.field(:int32, :value, acc, data)
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
defmodule Google.Protobuf.UInt32Value do
  @moduledoc false
  alias Pbuf.{Decoder, Encoder}
  import Bitwise, only: [bsr: 2, band: 2]

  alias __MODULE__

  defstruct [
    __pbuf__: true,
    value: 0
  ]

  @type t :: %UInt32Value{
    value: non_neg_integer
  }


  @spec new(Enum.t) :: t
  def new(data) do
    struct(__MODULE__, data)
  end

  @spec encode_to_iodata!(t | map) :: iodata
  def encode_to_iodata!(data) do
    alias Elixir.Pbuf.Encoder
    [
      Encoder.field(:uint32, data.value, <<8>>),
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
    Decoder.field(:uint32, :value, acc, data)
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
defmodule Google.Protobuf.BoolValue do
  @moduledoc false
  alias Pbuf.{Decoder, Encoder}
  import Bitwise, only: [bsr: 2, band: 2]

  alias __MODULE__

  defstruct [
    __pbuf__: true,
    value: false
  ]

  @type t :: %BoolValue{
    value: boolean
  }


  @spec new(Enum.t) :: t
  def new(data) do
    struct(__MODULE__, data)
  end

  @spec encode_to_iodata!(t | map) :: iodata
  def encode_to_iodata!(data) do
    alias Elixir.Pbuf.Encoder
    [
      Encoder.field(:bool, data.value, <<8>>),
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
    Decoder.field(:bool, :value, acc, data)
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
defmodule Google.Protobuf.StringValue do
  @moduledoc false
  alias Pbuf.{Decoder, Encoder}
  import Bitwise, only: [bsr: 2, band: 2]

  alias __MODULE__

  defstruct [
    __pbuf__: true,
    value: ""
  ]

  @type t :: %StringValue{
    value: String.t
  }


  @spec new(Enum.t) :: t
  def new(data) do
    struct(__MODULE__, data)
  end

  @spec encode_to_iodata!(t | map) :: iodata
  def encode_to_iodata!(data) do
    alias Elixir.Pbuf.Encoder
    [
      Encoder.field(:string, data.value, <<10>>),
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
    Decoder.field(:string, :value, acc, data)
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
defmodule Google.Protobuf.BytesValue do
  @moduledoc false
  alias Pbuf.{Decoder, Encoder}
  import Bitwise, only: [bsr: 2, band: 2]

  alias __MODULE__

  defstruct [
    __pbuf__: true,
    value: <<>>
  ]

  @type t :: %BytesValue{
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
      Encoder.field(:bytes, data.value, <<10>>),
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
    Decoder.field(:bytes, :value, acc, data)
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
