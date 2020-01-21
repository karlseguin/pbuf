alias Pbuf.Tests.{Everything, Child, Sub}

everything = %Everything{
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

binary = Pbuf.encode_to_iodata!(everything)

Benchee.run(%{
  "encode" => fn -> Pbuf.encode_to_iodata!(everything) end,
  "decode" => fn -> Pbuf.decode!(Everything, binary) end
})
