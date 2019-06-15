defmodule Pbuf.Encoder do
  import Bitwise, only: [bsr: 2, bsl: 2, bor: 2, band: 2]

  defmodule Error do
    defexception [:message, :value, :tag, :type]
  end

  @doc """
  Generates a field prefix. This is the tag number + wire type
  """
  @spec prefix(pos_integer, atom) :: binary
  def prefix(tag, type) do
    tag
    |> bsl(3)
    |> bor(wire_type(type))
    |> varint()
  end

  @spec wire_type(atom) :: integer
  def wire_type(:fixed64), do: 1
  def wire_type(:sfixed64), do: 1
  def wire_type(:double), do: 1
  def wire_type(:string), do: 2
  def wire_type(:bytes), do: 2
  def wire_type(:struct), do: 2
  def wire_type(:fixed32), do: 5
  def wire_type(:sfixed32), do: 5
  def wire_type(:float), do: 5
  def wire_type(_), do: 0 # varint

  @spec varint(integer) :: iodata
  for n <- (0..127) do
    def varint(unquote(n)) do
      <<unquote(n)>>
    end
  end

  def varint(n) when n < 0 do
    <<n::64-unsigned-native>> = <<n::64-signed-native>>
    varint(n)
  end

  def varint(n) do
    <<1::1, band(n, 127)::7, varint(bsr(n, 7))::binary>>
  end

  @spec zigzag(integer) :: integer
  def zigzag(val) when val >= 0 do
    val * 2
  end

  def zigzag(val) do
    val * -2 - 1
  end

  @doc """
  Encodes a value
  """
  @spec field(atom, any) :: iodata
  def field(:int32, n), do: varint(n)
  def field(:int64, n), do: varint(n)
  def field(:uint32, n), do: varint(n)
  def field(:uint64, n), do: varint(n)
  def field(:sint32, n), do: n |> zigzag |> varint
  def field(:sint64, n), do: n |> zigzag |> varint
  def field(:bool, n) when n == true, do: varint(1)
  def field(:bool, n) when n == false, do: varint(0)
  def field(:enum, n), do: field(:int32, n)
  def field(:fixed64, n), do: <<n::64-little>>
  def field(:sfixed64, n), do: <<n::64-signed-little>>
  def field(:double, n), do: <<n::64-float-little>>
  def field(:string, n), do: field(:bytes, n)
  def field(:fixed32, n), do: <<n::32-little>>
  def field(:sfixed32, n), do: <<n::32-signed-little>>
  def field(:float, n), do: <<n::32-float-little>>
  def field(:bytes, n) do
    bin = :erlang.iolist_to_binary(n)
    len = varint(byte_size(bin))
    <<len::binary, bin::binary>>
  end
  def field(:struct, n) do
    encoded = n.__struct__.encode_to_iodata!(n)
    len = varint(:erlang.iolist_size(encoded))
    [len, encoded]
  end

  @doc """
  Encodes a field. This means we encode the prefix + the value. We also do
  type checking and, omit any nil / default values.
  """
  @spec field(atom, any, binary) :: iodata
  # nil / defaults
  def field(_type, nil, _prefix), do: <<>>
  def field(:bool, false, _prefix), do: <<>>
  def field(:int32, 0, _prefix), do: <<>>
  def field(:int64, 0, _prefix), do: <<>>
  def field(:uint32, 0, _prefix), do: <<>>
  def field(:uint64, 0, _prefix), do: <<>>
  def field(:sint32, 0, _prefix), do: <<>>
  def field(:sint64, 0, _prefix), do: <<>>
  def field(:fixed32, 0, _prefix), do: <<>>
  def field(:fixed64, 0, _prefix), do: <<>>
  def field(:sfixed32, 0, _prefix), do: <<>>
  def field(:sfixed64, 0, _prefix), do: <<>>
  def field(:float, 0, _prefix), do: <<>>
  def field(:float, 0.0, _prefix), do: <<>>
  def field(:double, 0, _prefix), do: <<>>
  def field(:double, 0.0, _prefix), do: <<>>
  def field(:string, "", _prefix), do: <<>>
  def field(:bytes, <<>>, _prefix), do: <<>>

  @int32_max 0x7FFFFFFF
  @int32_min -0x80000000
  @int64_max 0x7FFFFFFFFFFFFFFF
  @int64_min -0x8000000000000000

  @uint32_max 0xFFFFFFFF
  @uint64_max 0xFFFFFFFFFFFFFFFF

  def field(:bool, true, prefix) do
    [prefix, <<1>>]
  end

  def field(:bool, val, prefix) do
    raise_invalid(:bool, val, prefix)
  end

  def field(:int32, val, prefix) when is_integer(val) and val <= @int32_max and val >= @int32_min do
    [prefix, field(:int32, val)]
  end

  def field(:int32, val, prefix)  do
    raise_invalid(:int32, val, prefix)
  end

  def field(:int64, val, prefix) when is_integer(val) and val <= @int64_max and val >= @int64_min do
    [prefix, field(:int64, val)]
  end

  def field(:int64, val, prefix)  do
    raise_invalid(:int64, val, prefix)
  end

  def field(:uint32, val, prefix) when is_integer(val) and val <= @uint32_max and val >= 0 do
    [prefix, field(:uint32, val)]
  end

  def field(:uint32, val, prefix)  do
    raise_invalid(:uint32, val, prefix)
  end

  def field(:uint64, val, prefix) when is_integer(val) and val <= @uint64_max and val >= 0 do
    [prefix, field(:uint64, val)]
  end

  def field(:uint64, val, prefix)  do
    raise_invalid(:uint64, val, prefix)
  end

  def field(:sint32, val, prefix) when is_integer(val) and val <= @int32_max and val >= @int32_min do
    [prefix, field(:sint32, val)]
  end

  def field(:sint32, val, prefix)  do
    raise_invalid(:sint32, val, prefix)
  end

  def field(:sint64, val, prefix) when is_integer(val) and val <= @int64_max and val >= @int64_min do
    [prefix, field(:sint64, val)]
  end

  def field(:sint64, val, prefix)  do
    raise_invalid(:sint64, val, prefix)
  end

  def field(:fixed32, val, prefix) when is_integer(val) and val <= @uint32_max and val >= 0 do
    [prefix, field(:fixed32, val)]
  end

  def field(:fixed32, val, prefix)  do
    raise_invalid(:fixed32, val, prefix)
  end

  def field(:fixed64, val, prefix) when is_integer(val) and val <= @uint64_max and val >= 0 do
    [prefix, field(:fixed64, val)]
  end

  def field(:fixed64, val, prefix)  do
    raise_invalid(:fixed64, val, prefix)
  end

  def field(:sfixed32, val, prefix) when is_integer(val) and val <= @int32_max and val >= @int32_min do
    [prefix, field(:sfixed32, val)]
  end

  def field(:sfixed32, val, prefix)  do
    raise_invalid(:sfixed32, val, prefix)
  end

  def field(:sfixed64, val, prefix) when is_integer(val) and val <= @int64_max and val >= @int64_min do
    [prefix, field(:sfixed64, val)]
  end

  def field(:sfixed64, val, prefix)  do
    raise_invalid(:sfixed64, val, prefix)
  end

  def field(:float, val, prefix) when is_number(val) do
    [prefix, field(:float, val)]
  end

  def field(:float, val, prefix)  do
    raise_invalid(:float, val, prefix)
  end

  def field(:double, val, prefix) when is_number(val) do
    [prefix, field(:double, val)]
  end

  def field(:double, val, prefix)  do
    raise_invalid(:double, val, prefix)
  end

  def field(:string, val, prefix) when is_binary(val) do
    [prefix, field(:string, val)]
  end

  def field(:string, val, prefix) when is_atom(val) do
    field(:string, Atom.to_string(val), prefix)
  end

  def field(:string, val, prefix) do
    raise_invalid(:string, val, prefix)
  end

  def field(:bytes, val, prefix) when is_binary(val) or is_list(val) do
    [prefix, field(:bytes, val)]
  end

  def field(:bytes, val, prefix) do
    raise_invalid(:bytes, val, prefix)
  end

  def field(:struct, %{__struct__: _} = val, prefix)  do
    [prefix, field(:struct, val)]
  end

  def field(:struct, val, prefix) do
    raise_invalid(:struct, val, prefix)
  end

  @spec enum_field(module, any, binary) :: iodata
  def enum_field(_mod, nil, _prefix) do
    <<>>
  end

  def enum_field(mod, val, prefix)  do
    field(:int32, mod.to_int(val), prefix)
  end

  @spec repeated_enum_field(module, any, binary) :: iodata
  def repeated_enum_field(_mod, nil, _prefix) do
    <<>>
  end

  def repeated_enum_field(_mod, [], _prefix) do
    <<>>
  end

  def repeated_enum_field(mod, vals, prefix) when is_list(vals) do
    encoded = Enum.reduce(vals, [], fn val, acc ->
      [acc, field(:int32, mod.to_int(val))]
    end)
    byte_size = :erlang.iolist_size(encoded)
    [prefix, varint(byte_size), encoded]
  end

  @spec map_field(binary, atom, binary, atom, any, binary) :: iodata
  def map_field(_kprefix, _ktype, _vprefix, _vtype, nil, _prefix) do
    <<>>
  end

  def map_field(_kprefix, _ktype, _vprefix, _vtype, map, _prefix) when map_size(map) == 0 do
    <<>>
  end

  def map_field(kprefix, ktype, vprefix, vtype, map, prefix) do
    Enum.reduce(map, [], fn {key, value}, acc ->
      bin = [
        field(ktype, key, kprefix),
        field(vtype, value, vprefix)
      ]
      len = :erlang.iolist_size(bin)
      [[prefix, varint(len), bin] | acc]
    end)
  end

  @spec repeated_field(atom, any, binary) :: iodata
  def repeated_field(_type, nil, _prefix) do
    <<>>
  end

  def repeated_field(_type, [], _prefix) do
    <<>>
  end

  # In proto3, only scalar numeric types are packed.
  def repeated_field(type, enum, prefix) when type in [:bytes, :string] do
    Enum.reduce(enum, [], fn value, acc ->
      [acc, prefix, field(type, value)]
    end)
  end

  def repeated_field(:struct, enum, prefix) do
    Enum.reduce(enum, [], fn value, acc ->
      [acc, field(:struct, value, prefix)]
    end)
  end

  def repeated_field(type, enum, prefix) do
    encoded = Enum.reduce(enum, [], fn value, acc ->
      [acc, field(type, value)]
    end)
    byte_size = :erlang.iolist_size(encoded)
    [prefix, varint(byte_size), encoded]
  end

  def repeated_unpacked_field(type, enum, prefix) do
    Enum.reduce(enum, [], fn value, acc ->
      [acc, prefix, field(type, value)]
    end)
  end

  def oneof_field(_choice, nil, _fun) do
    <<>>
  end

  def oneof_field(choice, {choice, value}, 0, fun) do
    fun.(value)
  end

  def oneof_field(choice, %{__type: choice, value: value}, 1, fun) do
    fun.(value)
  end

  def oneof_field(choice, value, 2, fun) when map_size(value) == 1 do
    case :maps.next(:maps.iterator(value)) do
      {^choice, value, :none} -> fun.(value)
      _ -> <<>>
    end
  end

  def oneof_field(_choice, _value, _, _prefix) do
    <<>>
  end

  @spec raise_invalid(atom, any, binary) :: no_return
  defp raise_invalid(type, val, <<prefix, _::binary>>) do
    tag = bsr(prefix, 3)
    raise Error,
      tag: tag,
      type: type,
      value: val,
      message: "#{inspect(val)} is not a valid #{type} (#{tag})"
  end
end
