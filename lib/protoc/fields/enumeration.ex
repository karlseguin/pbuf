defmodule Pbuf.Protoc.Fields.Enumeration do
  use Pbuf.Protoc.Field

  def new(desc, context) do
    {tag, name, _type, prefix} = extract_core(desc)

    full_name = module_name(desc)
    typespec = full_name <> ".t"

    context.package <> desc.name
    {base_fun, typespec, default} =
    case is_repeated?(desc) do
      false -> {"enum_field", typespec, ":#{context.global.enums[full_name].default}"}
      true -> {"repeated_enum_field", "[" <> typespec <> "]", "[]"}
    end

    %Field{
      tag: tag,
      name: name,
      prefix: prefix,
      default: default,
      typespec: typespec,
      encode_fun: "Encoder.#{base_fun}(#{full_name}, data.#{name}, #{prefix})",
      decode_fun: "Decoder.#{base_fun}(#{full_name}, :#{name}, acc, data)"
    }
  end
end
