defmodule Pbuf.Protoc.Fields.Simple do
  use Pbuf.Protoc.Field

  def new(desc, context) do
    typespec = typespec(desc)
    repeated = is_repeated?(desc)
    {tag, name, type, prefix} = extract_core(desc)

    {encode_fun, typespec, default} =
    case repeated do
      false -> {"field", typespec, default(context, type)}
      true -> {"repeated_field", "[" <> typespec <> "]", "[]"}
    end

    # length-prefixed types aren't packed, treat the decode as individual
    # fields and let something else worry about merging it
    decode_fun = cond do
      type == :struct -> "struct_field"  # special name largely because a module is an atom and we need to match between the two
      !repeated || type in [:bytes, :string] -> "field" # never packed
      true -> "repeated_field"
    end

    decode_type = case type == :struct do
      false -> ":#{type}"
      true -> module_name(desc)
    end

    post_decode = case repeated && type in [:bytes, :string, :struct] do
      true -> :repack
      false -> :none
    end

    %Field{
      tag: tag,
      name: name,
      prefix: prefix,
      default: default,
      typespec: typespec,
      post_decode: post_decode,
      encode_fun: "Encoder.#{encode_fun}(:#{type}, data.#{name}, #{prefix})",
      decode_fun: "Decoder.#{decode_fun}(#{decode_type}, :#{name}, acc, data)",
    }
  end

  @spec typespec(Protoc.proto_field | atom) :: String.t
  def typespec(%{type_name: t} = desc) when t not in [nil, ""] do
    module_name(desc) <> ".t"
  end

  def typespec(:bool), do: "boolean"
  def typespec(:bytes), do: "binary"
  def typespec(:string), do: "String.t"
  def typespec(:double), do: "number"
  def typespec(:float), do: "number"
  def typespec(:uint32), do: "non_neg_integer"
  def typespec(:uint64), do: "non_neg_integer"
  def typespec(other) when is_atom(other) do
    "integer"
  end
  def typespec(%{type: type}) do
    typespec(internal_type(type))
  end

  def default(%{version: 2}, _), do: "nil"

  def default(_, :bool), do: false
  def default(_, :bytes), do: "<<>>"
  def default(_, :string), do: ~s("")
  def default(_, :double), do: 0.0
  def default(_, :float), do: 0.0
  def default(_, :struct), do: "nil"
  def default(_, _other), do: 0
end
