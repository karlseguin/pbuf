defmodule Pbuf.Decoder do
  import Bitwise, only: [bsr: 2, bsl: 2, band: 2]

  defmodule Error do
    defexception [:module, :tag, :message]
  end

  @spec decode!(module, iodata) :: any
  def decode!(mod, data) do
    case decode(mod, data) do
      {:ok, decoded} -> decoded
      {:error, err} -> raise err
    end
  end

  @spec decode(module, iodata) :: {:ok, any} | {:error, any}
  def decode(mod, data) do
    data = :erlang.iolist_to_binary(data)
    case do_decode({[], data}, mod) do
      {:error, _} = err -> err
      acc ->
        # protoc rules say the last value read should overwrite previous ones
        acc = Enum.reverse(acc)
        {:ok, mod.__finalize_decode__(acc)}
    end
  end

  defp do_decode({acc, <<>>}, _mod) do
    acc
  end

  defp do_decode({:error, _} = err, _mod) do
    err
  end

  defp do_decode({acc, data}, mod) do
    do_decode(mod.decode(acc, data), mod)
  end

  # used when we have an unknown field and we want to skip the bytes
  @spec skip(non_neg_integer, binary) :: binary
  def skip(0, data) do
    {_, data} = varint(data)
    data
  end

  def skip(1, data) do
    <<_::bytes-size(8), data::binary>> = data
    data
  end

  def skip(2, data) do
    {len, data} = varint(data)
    <<_::bytes-size(len), data::binary>> = data
    data
  end

  def skip(5, data) do
    <<_::bytes-size(4), data::binary>> = data
    data
  end

  @spec field(atom, binary) :: {any, binary}
  def field(:bool, <<0, data::binary>>) do
    {false, data}
  end

  def field(:bool, <<1, data::binary>>) do
    {true, data}
  end

  def field(:int32, data) do
    {value, data} = varint(data)
    <<value::signed-integer-32>> = <<value::32>>
    {value, data}
  end

 def field(:int64, data) do
    {value, data} = varint(data)
    <<value::signed-integer-64>> = <<value::64>>
    {value, data}
  end

  def field(:uint32, data) do
    varint(data)
  end

  def field(:uint64, data) do
    varint(data)
  end

  def field(:sint32, data) do
    {value, data} = varint(data)
    {zigzag(value), data}
  end

  def field(:sint64, data) do
    {value, data} = varint(data)
    {zigzag(value), data}
  end

  def field(:fixed32, data) do
    <<value::little-32, data::binary>> = data
    {value, data}
  end

  def field(:sfixed32, data) do
    <<value::little-signed-32, data::binary>> = data
    {value, data}
  end

  def field(:fixed64, data) do
    <<value::little-64, data::binary>> = data
    {value, data}
  end

  def field(:sfixed64, data) do
    <<value::little-signed-64, data::binary>> = data
    {value, data}
  end

  def field(:float, data) do
    <<value::little-float-32, data::binary>> = data
    {value, data}
  end

  def field(:double, data) do
    <<value::little-float-64, data::binary>> = data
    {value, data}
  end

  # technically these don't need to be exposed, since they areonly called from
  # field/4 and never from a repeated field (only scalars are packed), but included
  # for consistency
  def field(:bytes, data) do
    {len, data} = varint(data)
    <<value::bytes-size(len), data::binary>> = data
    {value, data}
  end

  def field(:string, data) do
    field(:bytes, data)
  end

  def field(mod, data) do
    {len, data} = varint(data)
    <<embed_data::bytes-size(len), data::binary>> = data
    {decode(mod, embed_data), data}
  end

  @spec field(atom, atom, Keyword.t, binary) :: {Keyword.t, binary}
  def field(type, name, acc, data) do
    {value, data} = field(type, data)
    {[{name, value} | acc], data}
  end

  @spec struct_field(atom, atom, Keyword.t, binary) :: {Keyword.t, binary} | {:error, any}
  def struct_field(mod, name, acc, data) do
    case field(mod, data) do
      {{:ok, value}, data} -> {[{name, value} | acc], data}
      err -> err
    end
  end

  @spec enum_field(module, atom, Keyword.t, binary) :: {Keyword.t, binary}
  def enum_field(mod, name, acc, data) do
    {n, data} = varint(data)
    value = mod.from_int(n)
    {[{name, value} | acc], data}
  end

  @spec oneof_field(atom, {Keyword.t, binary}) :: {Keyword.t, binary}
  def oneof_field(name, {acc, data}) do
    # pop the last k=>v added to our acc, which is the hidden oneof field
    # and replace it with a the same value, but with our exposed key names
    [{inner_name, value} | acc] = acc
    {[{name, {inner_name, value}} | acc], data}
  end

  # length-prefixed repeated fields are never packed. That's ok. Our decode method
  # calls Decoder.field/4 on those, and we'll get duplicates in acc which our
  # top level Decoder.decode/2 function will efficiently merge.
  @spec repeated_field(atom, atom, Keyword.t, binary) :: {Keyword.t, binary}
  def repeated_field(type, name, acc, data) do
    {l, data} = varint(data)
    <<repeated_data::bytes-size(l), data::binary>> = data
    values = decoded_repeated(type, repeated_data, [])
    {[{name, values} | acc], data}
  end

  defp decoded_repeated(_type, <<>>, acc) do
    Enum.reverse(acc)
  end

  defp decoded_repeated(type, data, acc) do
    {value, data} = field(type, data)
    decoded_repeated(type, data, [value | acc])
  end

  @spec repeated_enum_field(atom, atom, Keyword.t, binary) :: {Keyword.t, binary}
  def repeated_enum_field(mod, name, acc, data) do
    {l, data} = varint(data)
    <<repeated_data::bytes-size(l), data::binary>> = data
    values = decoded_repeated_enum(mod, [], repeated_data)
    {[{name, values} | acc], data}
  end

  defp decoded_repeated_enum(_mod, acc, <<>>) do
    Enum.reverse(acc)
  end

  defp decoded_repeated_enum(mod, acc, data) do
    {value, data} = varint(data)
    value = mod.from_int(value)
    decoded_repeated_enum(mod, [value | acc], data)
  end

  # 11 parameters!!!
  # the key prefix (kp) and value prefix (vp) are bytes because the tag is only 1 or 2
  # and thus cannot be > 255. We use this trick to [slighly] make this map handling
  # a little less crazy (it's still not great.)
  @spec map_field(byte, atom, any, byte, atom, any, atom, Keyword.t, binary) :: {Keyword.t, binary} | {:error, Error.t}
  def map_field(kp, kt, kd, vp, vt, vd, name, acc, data) do
    defaults = {kd, vd}
    {l, data} = varint(data)
    case l == 0 do
      true -> {[{name, defaults} | acc], data}
      false ->
        <<map::bytes-size(l), data::binary>> = data
        case do_map_field(kp, kt, vp, vt, defaults, map) do
          {:error, _} = err -> err
          kv -> {[{name, kv} | acc], data}
        end
    end
  end

  # I struggled with this (doing it cleanly and efficiently).
  # A map is encoded as a struct with two fields. They key is always at tag 1,
  # the value at tag 2. However, like any struct, there's ordering requirement
  # further, either could be missing/defaults (or both, but we handled the case
  # above with our l == 0 check).
  # However, because we only have tag 1 or tag 2, we know the prefix will always
  # be 1 byte. This makes all the difference to doing this cleanly because we
  # can now just extrac tthat first byte and match it against the key prefix (kp)
  # and the value prefix (vp).
  defp do_map_field(kp, kt, vp, vt, {k, v}, <<prefix, data::binary>>) do
    res = cond do
      prefix == kp ->
        {key, data} = field(kt, data)
        {{key, v}, data}
      prefix == vp ->
        case field(vt, data) do
          {:error, _} = err -> err
          {{:ok, value}, data} -> {{k, value}, data}
          {value, data} -> {{k, value}, data}
        end
      true ->
        # shouldn't happen
        {:error, %Error{message: "unexpected map data: #{inspect(data)}"}}
    end

    case res do
      {:error, _} = err -> err
      {:incomplete, _} = err -> err
      {acc, <<>>} -> acc
      {acc, data} -> do_map_field(kp, kt, vp, vt, acc, data)
    end
  end

  @spec varint(binary) :: {integer, binary}
  def varint(<<>>) do
    {0, <<>>}
  end

  for i <- (1..127) do
    def varint(<<0::1, unquote(i)::7, data::binary>>) do
      {unquote(i), data}
    end
  end

  def varint(bin) do
    varint(bin, 0, 0)
  end

  defp varint(<<1::1, value::7, data::binary>>, position, acc) do
    varint(data, position + 7, bsl(value, position) + acc)
  end

  @mask bsl(1, 64) - 1
  defp varint(<<0::1, value::7, data::binary>>, position, acc) do
    acc = value
    |> bsl(position)
    |> Kernel.+(acc)
    |> band(@mask)

    {acc, data}
  end

  @spec zigzag(integer) :: integer
  def zigzag(n) when band(n, 1) == 0 do
    bsr(n, 1)
  end

  def zigzag(n) do
    -bsr(n + 1, 1)
  end
end
