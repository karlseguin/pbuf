defmodule Pbuf.Tests.Integration do
  @moduledoc """
  We test by encoding with our library, but decoding with the Protobuf library
  which helps make sure that we don't just have buggy code shared between our
  encoder and decoder
  """
  use Pbuf.Tests.Base

  alias Pbuf.Tests.{Child, Everything, Sub}

  test "encode/decode default values" do
    expected = %{
      bool: false, int32: 0, int64: 0, uint32: 0, uint64: 0, sint32: 0, sint64: 0,
      fixed32: 0, sfixed32: 0, fixed64: 0, sfixed64: 0, float: 0.0, double: 0.0,
      string: "" , bytes: "", struct: nil, type: :EVERYTHING_TYPE_UNKNOWN, corpus: :universal,
      choice: nil, user: nil, user_status: :USER_STATUS_UNKNOWN,

      bools: [], int32s: [], int64s: [], uint32s: [],
      uint64s: [], sint32s: [], sint64s: [], fixed32s: [], sfixed32s: [], fixed64s: [],
      sfixed64s: [], floats: [], doubles: [], strings: [], bytess: [], structs: [],
      types: [], corpuss: [],
      map1: %{}, map2: %{}, map3: %{},
    }
    assert_value(encode_decode(%Everything{}), expected)
  end

  test "encode/decode non-default values" do
    values = %{
      bool: true, int32: -21, int64: -9922232, uint32: 82882, uint64: 199922332321984,
      sint32: -221331, sint64: -29, fixed32: 4294967295, sfixed32: -2147483647,
      fixed64: 1844674407370955161, sfixed64: -9223372036854775807,
      float: 2.5, double: -3.551, string: "over", bytes: <<9, 0, 0, 0>>,
      struct: %Child{id: 9001, name: "goku"}, type: :EVERYTHING_TYPE_SAND, corpus: :web,
      choice: {:choice_int32, 299}, user: %Sub.User{id: 1, status: 1}, user_status: :USER_STATUS_NORMAL,

      bools: [true], int32s: [-21], int64s: [-9922232], uint32s: [82882], uint64s: [199922332321984],
      sint32s: [-221331], sint64s: [-29], fixed32s: [4294967295], sfixed32s: [-2147483647],
      fixed64s: [1844674407370955161], sfixed64s: [-9223372036854775807],
      floats: [2.5], doubles: [-3.551], strings: ["over"],
      bytess: [<<9, 0, 0, 0>>], map1: %{"over" => 9000}, map2: %{999999999999999 => 2.5},
      structs: [%Child{id: 18, name: "tea"}],
      types: [:EVERYTHING_TYPE_SAND], corpuss: [:products],
      map3: %{9001 => %Child{id: 9001, name: "gohan"}}
    }

    everything = encode_decode(struct(Everything, values))
    assert_value(everything, values)
  end

  test "encode/decode multi-value arrays" do
    values = %{
      bool: true, int32: 0, int64: 0, uint32: 0, uint64: 0,
      sint32: 0, sint64: 0, fixed32: 0, sfixed32: 0,
      fixed64: 0, sfixed64: 0, float: 0, double: 0, string: "", bytes: "",
      struct: nil, type: :EVERYTHING_TYPE_UNKNOWN, corpus: :universal, choice: {:choice_string, "use this test for this"},
      user: nil, user_status: :USER_STATUS_UNKNOWN,

      bools: [true, false], int32s: [-21, 32], int64s: [-9922232, 9922232],
      uint32s: [82882, 323], uint64s: [199922332321984, 3223001],
      sint32s: [-221331, 221331], sint64s: [-29, 29],
      fixed32s: [4294967295, 0, 1], sfixed32s: [1, 2, 3, 4, 5],
      fixed64s: [192, 391, 12],
      sfixed64s: [-2, 2, 93, 11, -293321938],
      floats: [2.5, 0, -5.50, 299381.0], doubles: [-3.551, 3.551], strings: ["over", "9000", "", "!"],
      bytess: [<<9, 0, 0, 0>>, <<2, 0>>],
      structs: [%Child{id: 1, name: "a"}, %Child{id: 18, name: "black 🍵"}],
      types: [:EVERYTHING_TYPE_UNKNOWN, :EVERYTHING_TYPE_SAND],
      corpuss: [:web, :news, :video],
      map1: %{"over" => 9000, "spice" => 1337}, map2: %{-999999999999999 => -2.5, 0 => 1},
      map3: %{0 => %Child{id: 0, name: ""}, 18 => %Child{id: 18, name: "black 🍵"}}
    }

    everything = encode_decode(struct(Everything, values))
    assert_value(everything, values)
  end

  test "encodes and decodes json" do
    child = Child.new(data2: %{over: 9000}, data3: %{over: 9001})
    child = Child.decode!(Child.encode!(child))
    assert child.data2 == %{"over" => 9000}
    assert child.data3 == %{over: 9001}
  end

  test "encodes oneof as tuple" do
    oneof = OneOfZero.decode!(Pbuf.encode!(OneOfZero.new(choice: {:a, 2})))
    assert oneof.choice == {:a, 2}
  end

  test "encodes oneof as choice map" do
    oneof = OneOfOne.decode!(Pbuf.encode!(OneOfOne.new(choice: %{__type: :a, value: 3})))
    assert oneof.choice == %{__type: :a, value: 3}
  end

  test "encodes oneof as field map" do
    oneof = OneOfTwo.decode!(Pbuf.encode!(OneOfTwo.new(choice: %{b: 4})))
    assert oneof.choice == %{b: 4}
  end

  test "oneof with json encoding value" do
    oneof = OneOfZero.decode!(OneOfZero.encode!(OneOfZero.new(json: {:value, %{over: 9000}})))
    assert oneof.json == {:value, %{"over" => 9000}}

    oneof = OneOfOne.decode!(OneOfOne.encode!(OneOfOne.new(json: %{__type: :value, value: %{over: 9000}})))
    assert oneof.json == %{__type: :value, value: %{"over" => 9000}}

    oneof = OneOfTwo.decode!(OneOfTwo.encode!(OneOfTwo.new(json: %{value: %{over: 9001}})))
    assert oneof.json == %{value: %{"over" => 9001}}
  end

  test "json encoding" do
    e = Everything.new(bool: true, int32: 1, int64: 3, sint64: 4, sfixed32: 5, sfixed64: 6)
    e = e |> Jason.encode!() |> Jason.decode!(keys: :atoms)
    assert Map.has_key?(e, :sint64) == false
    assert Map.has_key?(e, :sfixed64) == false

    assert Map.has_key?(e, :bool) == true
    assert Map.has_key?(e, :int32) == true
    assert Map.has_key?(e, :sfixed32) == true
  end

  # decode using both our own library and Protobuf as a sanity check
  defp encode_decode(struct) do
    encoded = Pbuf.encode!(struct)

    mod = struct.__struct__
    sanity = Module.concat(Sanity, mod)
    pbuf = Pbuf.Decoder.decode!(mod, encoded)
    protobuf = Protobuf.Decoder.decode(encoded, sanity)
    [pbuf: pbuf, protobuf: protobuf]
  end

  defp assert_value([pbuf: pbuf, protobuf: protobuf], expected) do
    assert_value(pbuf, expected, :pbuf)
    assert_value(protobuf, expected, :protobuf)
  end

  # We need to strip out the __struct__ since they're actually different. We
  # encoded an Everything and Child, but since we're using a different decoder
  # we get back an Everything.Sanity and Child.Sanity.
  defp assert_value(%{__struct__: _} = actual, expected, type) do
    actual = Map.from_struct(actual)
    expected = case Map.has_key?(expected, :__struct__) do
      true -> Map.from_struct(expected)
      false -> expected
    end
    assert_value(actual, expected, type)
  end

  defp assert_value(actual, expected, type) when is_map(actual) do
    Enum.each(actual, fn
      {:__pbuf__, true} -> :ok
      {k, v} -> assert_value(v, Map.get(expected, k), type)
    end)
  end

  defp assert_value([a | actual], [e | expected], type) do
    assert_value(a, e, type)
    assert_value(actual, expected, type)
  end

  # not sure how else to handle the mismatch for how we handle enums
  defp assert_value(:UNIVERSAL, :universal, :protobuf), do: :ok
  defp assert_value(:WEB, :web, :protobuf), do: :ok
  defp assert_value(:NEWS, :news, :protobuf), do: :ok
  defp assert_value(:PRODUCTS, :products, :protobuf), do: :ok
  defp assert_value(:VIDEO, :video, :protobuf), do: :ok

  defp assert_value(:USER_STATUS_NORMAL, 1, :pbuf), do: :ok
  defp assert_value(:USER_STATUS_NORMAL, 1, :protobuf), do: :ok

  defp assert_value(actual, expected, _type) do
    assert actual == expected, "#{inspect(actual)} != #{inspect(expected)}"
  end
end
