defmodule Pbuf.Protoc.Field do
  alias Pbuf.Protoc
  alias Pbuf.Protoc.Fields

  @enforce_keys [:tag, :name, :prefix, :typespec, :encode_fun, :decode_fun, :default]
  defstruct @enforce_keys ++ [
    hidden: false,
    oneof_index: nil,
    post_decode: :none,
  ]

  @type t :: %__MODULE__{
    tag: pos_integer,
    name: String.t,
    prefix: binary,
    typespec: String.t,
    encode_fun: String.t,
    decode_fun: String.t,
    default: String.t,
    hidden: boolean,
    oneof_index: nil | non_neg_integer,
    post_decode: :none | :map | :repack
  }

  defmacro __using__(_opts) do
    quote do
      alias Pbuf.Protoc.Field
      import Pbuf.Protoc.Field
    end
  end

  # returns a type that implements the Field protocol
  @spec build(Protoc.proto_field, Context.t) :: any
  def build(desc, context) do
    case get_type(desc, context) do
      :map -> Fields.Map.new(desc, context)
      :oneof -> Fields.OneOf.new(desc, context)
      :simple -> Fields.Simple.new(desc, context)
      :enum -> Fields.Enumeration.new(desc, context)
    end
  end

  @spec get_type(Protoc.proto_field, Context.t) :: :map | :oneof | :enum | :simple
  defp get_type(desc, context) do
    with {false, _} <- {is_map?(desc.type_name, context.maps), :map},
         {false, _} <- {is_oneof?(desc.oneof_index, context), :oneof},
         {false, _} <- {is_enum?(desc.type), :enum}
    do
      :simple
    else
      {true, type} -> type
    end
  end

  defp is_enum?(type) do
    internal_type(type) == :enum
  end

  defp is_oneof?(nil, _ctx) do
    false
  end

  defp is_oneof?(0, %{oneofs: m}) when map_size(m) == 0 do
    false
  end

  defp is_oneof?(_index, _ctx) do
    true
  end

  defp is_map?(nil, _maps) do
    false
  end

  defp is_map?(type_name, maps) do
    Enum.any?(maps, fn {name, _value} ->
      String.ends_with?(type_name, name)
    end)
  end

  # helpers for actual field builders
  def module_name(%{type_name: <<".", type::binary>>}) do
    type
    |> String.split(".")
    |> Enum.map(&Protoc.capitalize_first/1)
    |> Enum.join(".")
  end

  @spec is_repeated?(Protoc.proto_field) :: boolean
  def is_repeated?(desc) do
    desc.label == :LABEL_REPEATED
  end

  @spec extract_core(Protoc.proto_field) :: {non_neg_integer, String.t, atom, binary}
  def extract_core(desc) do
    tag = desc.number
    name = desc.name
    type = internal_type(desc.type)

    prefix = case is_repeated?(desc) do
      true -> Pbuf.Encoder.prefix(tag, :bytes) # bytes share the same encoding type as any type of array
      false -> Pbuf.Encoder.prefix(tag, type)
    end
    {tag, name, type, stringify_binary(prefix)}
  end

  @spec internal_type(byte | atom) :: atom
  def internal_type(:TYPE_BOOL), do: :bool
  def internal_type(:TYPE_BYTES), do: :bytes
  def internal_type(:TYPE_STRING), do: :string
  def internal_type(:TYPE_DOUBLE), do: :double
  def internal_type(:TYPE_FLOAT), do: :float
  def internal_type(:TYPE_INT32), do: :int32
  def internal_type(:TYPE_INT64), do: :int64
  def internal_type(:TYPE_SINT32), do: :sint32
  def internal_type(:TYPE_SINT64), do: :sint64
  def internal_type(:TYPE_FIXED32), do: :fixed32
  def internal_type(:TYPE_FIXED64), do: :fixed64
  def internal_type(:TYPE_SFIXED32), do: :sfixed32
  def internal_type(:TYPE_SFIXED64), do: :sfixed64
  def internal_type(:TYPE_UINT32), do: :uint32
  def internal_type(:TYPE_UINT64), do: :uint64
  def internal_type(:TYPE_MESSAGE), do: :struct
  def internal_type(:TYPE_ENUM), do: :enum

  def stringify_binary(bin) do
    s = bin
    |> :erlang.binary_to_list()
    |> Enum.map(&Integer.to_string/1)
    |> Enum.join(", ")
    "<<#{s}>>"
  end
end
