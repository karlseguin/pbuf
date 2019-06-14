defmodule Pbuf.Protoc.Fields.OneOf do
  use Pbuf.Protoc.Field

  def new(desc, context) do
    index = desc.oneof_index
    oneof = context.oneofs[index]
    {tag, name, _type, prefix} = extract_core(desc)

    # Get this field as though it wasn't a oneof
    pseudo = build(Map.put(desc, :oneof_index, nil), context)

    # The way we do this is aweful. We generate the encode_fun/decode_fun for the
    # field as though it wasn't a oneof (because that's almost what we want)
    # then string replace out the parts we don't want.

    pseudo_encode_fun = pseudo
    |> Map.get(:encode_fun)
    |> String.replace("data.#{name}", "v")
    encode_fun = "oneof_field(:#{name}, data.#{oneof.name}, #{context.oneof_format}, fn v -> #{pseudo_encode_fun} end)"

    pseudo_decode_fun = Map.get(pseudo, :decode_fun)
    decode_fun = "oneof_field(:#{oneof.name}, #{context.oneof_format}, #{pseudo_decode_fun})"

    post_decode = case context.oneof_format do
      1 -> :oneof1
      2 -> :oneof2
      _ -> :none
    end

    %Field{
      tag: tag,
      name: name,
      prefix: prefix,
      hidden: true,
      default: "nil",
      oneof_index: index,
      post_decode: post_decode,
      typespec: pseudo.typespec,
      encode_fun: "Encoder.#{encode_fun}",
      decode_fun: "Decoder.#{decode_fun}"
    }
  end
end
