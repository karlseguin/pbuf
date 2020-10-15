defmodule Pbuf.Protoc.Template do
  require EEx

  EEx.function_from_file(:def, :message,
    Path.expand("./templates/message.eex", __DIR__),
    [:name, :fields, :enums, :context, :options],
    trim: false
  )

  EEx.function_from_file(:def, :enumeration,
    Path.expand("./templates/enumeration.eex", __DIR__),
    [:e, :embed?],
    trim: false
  )

  defp if_neq(a, b, text) do
    if a != b do
      text
    end
  end
end
