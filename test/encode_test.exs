defmodule Pbuf.Tests.Encode do
  use Pbuf.Tests.Base

  alias Pbuf.Tests.Sub.User
  alias Pbuf.Tests.Everything

  test "raises on invalid type" do
    assert_scalar_invalid(:bool, [1, :yes], 1)
    assert_scalar_invalid(:int32, [2.2, true, false, :they, "are", 0x7FFFFFFF + 1, -0x80000000 - 1], 2)
    assert_scalar_invalid(:uint32, [2.2, true, false, :alone, "they", 0xFFFFFFFF + 1, -1], 4)
    assert_scalar_invalid(:sint32, [2.2, true, false, :are, "a", 0x7FFFFFFF + 1, -0x80000000 - 1], 6)
    assert_scalar_invalid(:fixed32, [2.2, true, false, :dying, "people", 0xFFFFFFFF + 1, -1], 8)
    assert_scalar_invalid(:sfixed32, [2.2, true, false, :we, "should", 0x7FFFFFFF + 1, -0x80000000 - 1], 10)

    assert_scalar_invalid(:int64, [2.2, true, false, :let, "them", 0x7FFFFFFFFFFFFFFF + 1, -0x8000000000000000 - 1], 3)
    assert_scalar_invalid(:uint64, [2.2, true, false, :pass, "the", 0xFFFFFFFFFFFFFFFF + 1, -1], 5)
    assert_scalar_invalid(:sint64, [2.2, true, false, :narn, "or", 0x7FFFFFFFFFFFFFFF + 1, -0x8000000000000000 - 1], 7)
    assert_scalar_invalid(:fixed64, [2.2, true, false, :the, "centauri", 0xFFFFFFFFFFFFFFFF + 1, -1], 9)
    assert_scalar_invalid(:sfixed64, [2.2, true, false, :yes, ".", 0x7FFFFFFFFFFFFFFF + 1, -0x8000000000000000 - 1], 11)

    assert_scalar_invalid(:float, [true, false, :yes, "."], 12)
    assert_scalar_invalid(:double, [true, false, :yes, "."], 13)

    assert_scalar_invalid(:string, [true, false, :yes, 1, -2.0], 14)
    assert_values_invalid(:bytes, [true, false, :yes, -3991, 99.2, %{}], 15)

    assert_values_invalid(:struct, [true, false, :yes, -3991, 99.2, %{}], 16)
  end

  test "invalid enums" do
    assert_enum_values_invalid(:type, [3, true, false, %{}], Pbuf.Tests.EverythingType)
  end

  test "enum with atom or integer" do
    assert Pbuf.encode!(Everything.new(type: :EVERYTHING_TYPE_UNKNOWN)) == <<>>
    assert Pbuf.encode!(Everything.new(type: :EVERYTHING_TYPE_SAND)) == <<136, 1, 1>>
    assert Pbuf.encode!(Everything.new(type: :EVERYTHING_TYPE_SPICE)) == <<136, 1, 2>>

    assert Pbuf.encode!(Everything.new(type: nil)) == <<>>
    assert Pbuf.encode!(Everything.new(type: 0)) == <<>>
    assert Pbuf.encode!(Everything.new(type: 0)) == <<>>
    assert Pbuf.encode!(Everything.new(type: 1)) == <<136, 1, 1>>
    assert Pbuf.encode!(Everything.new(type: 2)) == <<136, 1, 2>>

    assert Pbuf.encode!(Everything.new(types: [2])) == <<250, 2, 1, 2>>
    assert Pbuf.encode!(Everything.new(types: [:EVERYTHING_TYPE_SPICE])) == <<250, 2, 1, 2>>
  end

  test "bytes can encode an iolist" do
    assert Pbuf.encode!(Everything.new(bytes: [65, [2, 3]])) == <<122, 3, 65, 2, 3>>
  end

  test "nested messages" do
    user = User.new(name: User.Name.new(first: "leto", last: "atreides"))
    user = User.decode!(User.encode!(user))
    assert user.name == %User.Name{first: "leto", last: "atreides"}
  end

  test "packageless messages" do
    a = %A{b: %A.B{c: %A.B.C{d: 3}}}
    a = A.decode!(A.encode!(a))
    assert a.b.c.d == 3
  end

  defp assert_scalar_invalid(type, values, tag) do
    assert_values_invalid(type, [[], %{}, ~D[2018-07-01]] ++ values, tag)
  end

  defp assert_values_invalid(type, values, tag) do
    for value <- values do
      assert_invalid(type, value, tag)
    end
  end

  defp assert_invalid(type, value, tag) do
    Pbuf.encode!(Everything.new(%{type => value}))
    flunk("expecting #{type} with a value of #{value} to raise an exception")
  rescue
    e in Pbuf.Encoder.Error ->
      assert e.tag == tag
      assert e.type == type
      assert e.value == value
  end

   defp assert_enum_values_invalid(type, values, mod) do
    for value <- values do
      assert_enum_invalid(type, value, mod)
    end
  end

  defp assert_enum_invalid(type, value, mod) do
    Pbuf.encode!(Everything.new(%{type => value}))
    flunk("expecting #{type} with a value of #{value} to raise an exception")
  rescue
    e in Pbuf.Encoder.Error ->
      assert e.tag == nil
      assert e.type == mod
      assert e.value == value
  end
end
