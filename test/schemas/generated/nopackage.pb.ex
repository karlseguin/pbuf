defmodule A do
  @moduledoc false
  alias Pbuf.Decoder
  
  @derive {Jason.Encoder, []}
  defstruct [
    b: nil
  ]

  @type t :: %__MODULE__{
    b: A.B.t
  }
  
  @spec new(Enum.t) :: t
  def new(data \\ []), do: struct(__MODULE__, data)
  
  @spec encode_to_iodata!(t | map) :: iodata
  def encode_to_iodata!(data) do
    alias Elixir.Pbuf.Encoder
    [
      Encoder.field(:struct, data.b, <<10>>),
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
    Decoder.struct_field(A.B, :b, acc, data)
  end
  
  import Bitwise, only: [bsr: 2, band: 2]
  
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
      
      
      
      
      
      {k, v}, acc -> Map.put(acc, k, v)
    end)
    struct
  end
end
defmodule A.B do
  @moduledoc false
  alias Pbuf.Decoder
  
  @derive {Jason.Encoder, []}
  defstruct [
    c: nil
  ]

  @type t :: %__MODULE__{
    c: A.B.C.t
  }
  
  @spec new(Enum.t) :: t
  def new(data \\ []), do: struct(__MODULE__, data)
  
  @spec encode_to_iodata!(t | map) :: iodata
  def encode_to_iodata!(data) do
    alias Elixir.Pbuf.Encoder
    [
      Encoder.field(:struct, data.c, <<10>>),
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
    Decoder.struct_field(A.B.C, :c, acc, data)
  end
  
  import Bitwise, only: [bsr: 2, band: 2]
  
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
      
      
      
      
      
      {k, v}, acc -> Map.put(acc, k, v)
    end)
    struct
  end
end
defmodule A.B.C do
  @moduledoc false
  alias Pbuf.Decoder
  
  @derive {Jason.Encoder, []}
  defstruct [
    d: 0
  ]

  @type t :: %__MODULE__{
    d: integer
  }
  
  @spec new(Enum.t) :: t
  def new(data \\ []), do: struct(__MODULE__, data)
  
  @spec encode_to_iodata!(t | map) :: iodata
  def encode_to_iodata!(data) do
    alias Elixir.Pbuf.Encoder
    [
      Encoder.field(:int32, data.d, <<16>>),
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
    Decoder.field(:int32, :d, acc, data)
  end
  
  import Bitwise, only: [bsr: 2, band: 2]
  
  # failed to decode, either this is an unknown tag (which we can skip), or
  # it is a wrong type (which is an error)
  def decode(acc, data) do
    {prefix, data} = Decoder.varint(data)
    tag = bsr(prefix, 3)
    type = band(prefix, 7)
    case tag in [2] do
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
