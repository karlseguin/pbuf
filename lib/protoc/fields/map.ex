defmodule Pbuf.Protoc.Fields.Map do
  use Pbuf.Protoc.Field

  alias Pbuf.Encoder
  alias Pbuf.Protoc.Fields.Simple

  def new(desc, context) do
    type_name = desc.type_name
    {tag, name, _type, prefix} = extract_core(desc)

    {_name, {key_field, value_field}} = Enum.find(context.maps, fn {name, _value} ->
      String.ends_with?(type_name, name)
    end)
    ktype = internal_type(key_field.type)
    vtype = internal_type(value_field.type)

    kprefix = Encoder.prefix(1, ktype)
    vprefix = Encoder.prefix(2, vtype)

    decode_type =
    case vtype == :struct do
      true -> module_name(value_field)
      false -> ":#{vtype}"
    end

    <<bkprefix::8>> = kprefix
    <<bvprefix::8>> = vprefix

    skprefix = stringify_binary(kprefix)
    svprefix = stringify_binary(vprefix)

    kdefault = Simple.default(ktype)
    vdefault = Simple.default(vtype)

    # don't have enough information on vtype to know the actual value type
    # (the only reason we have enough for the key is that, as per the specs,
    # it has to be a scalar)
    typespec = "%{optional(#{Simple.typespec(ktype)}) => any}"
    encode_fun = "Encoder.map_field(#{skprefix}, :#{ktype}, #{svprefix}, :#{vtype}, data.#{name}, #{prefix})"
    decode_fun = "post_map(:#{name}, #{tag}, Decoder.map_field(#{bkprefix}, :#{ktype}, #{kdefault}, #{bvprefix}, #{decode_type}, #{vdefault}, :#{name}, acc, data))"

    %Field{
      tag: tag,
      name: name,
      prefix: prefix,
      default: "%{}",
      post_decode: :map,
      typespec: typespec,
      encode_fun: encode_fun,
      decode_fun: decode_fun
    }
  end
end
