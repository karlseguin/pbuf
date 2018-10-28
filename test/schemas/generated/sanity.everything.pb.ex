defmodule Sanity.Pbuf.Tests.Everything do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          choice: {atom, any},
          bool: boolean,
          int32: integer,
          int64: integer,
          uint32: non_neg_integer,
          uint64: non_neg_integer,
          sint32: integer,
          sint64: integer,
          fixed32: non_neg_integer,
          fixed64: non_neg_integer,
          sfixed32: integer,
          sfixed64: integer,
          float: float,
          double: float,
          string: String.t(),
          bytes: String.t(),
          struct: Sanity.Pbuf.Tests.Child.t(),
          type: integer,
          corpus: integer,
          user: Sanity.Pbuf.Tests.Sub.User.t(),
          user_status: integer,
          bools: [boolean],
          int32s: [integer],
          int64s: [integer],
          uint32s: [non_neg_integer],
          uint64s: [non_neg_integer],
          sint32s: [integer],
          sint64s: [integer],
          fixed32s: [non_neg_integer],
          sfixed32s: [integer],
          fixed64s: [non_neg_integer],
          sfixed64s: [integer],
          floats: [float],
          doubles: [float],
          strings: [String.t()],
          bytess: [String.t()],
          structs: [Sanity.Pbuf.Tests.Child.t()],
          types: [integer],
          corpuss: [integer],
          map1: %{String.t() => integer},
          map2: %{integer => float},
          map3: %{non_neg_integer => Sanity.Pbuf.Tests.Child.t()}
        }
  defstruct [
    :choice,
    :bool,
    :int32,
    :int64,
    :uint32,
    :uint64,
    :sint32,
    :sint64,
    :fixed32,
    :fixed64,
    :sfixed32,
    :sfixed64,
    :float,
    :double,
    :string,
    :bytes,
    :struct,
    :type,
    :corpus,
    :user,
    :user_status,
    :bools,
    :int32s,
    :int64s,
    :uint32s,
    :uint64s,
    :sint32s,
    :sint64s,
    :fixed32s,
    :sfixed32s,
    :fixed64s,
    :sfixed64s,
    :floats,
    :doubles,
    :strings,
    :bytess,
    :structs,
    :types,
    :corpuss,
    :map1,
    :map2,
    :map3
  ]

  oneof :choice, 0
  field :bool, 1, type: :bool
  field :int32, 2, type: :int32
  field :int64, 3, type: :int64
  field :uint32, 4, type: :uint32
  field :uint64, 5, type: :uint64
  field :sint32, 6, type: :sint32
  field :sint64, 7, type: :sint64
  field :fixed32, 8, type: :fixed32
  field :fixed64, 9, type: :fixed64
  field :sfixed32, 10, type: :sfixed32
  field :sfixed64, 11, type: :sfixed64
  field :float, 12, type: :float
  field :double, 13, type: :double
  field :string, 14, type: :string
  field :bytes, 15, type: :bytes
  field :struct, 16, type: Sanity.Pbuf.Tests.Child
  field :type, 17, type: Sanity.Pbuf.Tests.EverythingType, enum: true
  field :corpus, 18, type: Sanity.Pbuf.Tests.Everything.Corpus, enum: true
  field :choice_int32, 19, type: :int32, oneof: 0
  field :choice_string, 20, type: :string, oneof: 0
  field :user, 21, type: Sanity.Pbuf.Tests.Sub.User
  field :user_status, 22, type: Sanity.Pbuf.Tests.Sub.UserStatus, enum: true
  field :bools, 31, repeated: true, type: :bool
  field :int32s, 32, repeated: true, type: :int32
  field :int64s, 33, repeated: true, type: :int64
  field :uint32s, 34, repeated: true, type: :uint32
  field :uint64s, 35, repeated: true, type: :uint64
  field :sint32s, 36, repeated: true, type: :sint32
  field :sint64s, 37, repeated: true, type: :sint64
  field :fixed32s, 38, repeated: true, type: :fixed32
  field :sfixed32s, 39, repeated: true, type: :sfixed32
  field :fixed64s, 40, repeated: true, type: :fixed64
  field :sfixed64s, 41, repeated: true, type: :sfixed64
  field :floats, 42, repeated: true, type: :float
  field :doubles, 43, repeated: true, type: :double
  field :strings, 44, repeated: true, type: :string
  field :bytess, 45, repeated: true, type: :bytes
  field :structs, 46, repeated: true, type: Sanity.Pbuf.Tests.Child
  field :types, 47, repeated: true, type: Sanity.Pbuf.Tests.EverythingType, enum: true
  field :corpuss, 48, repeated: true, type: Sanity.Pbuf.Tests.Everything.Corpus, enum: true
  field :map1, 61, repeated: true, type: Sanity.Pbuf.Tests.Everything.Map1Entry, map: true
  field :map2, 62, repeated: true, type: Sanity.Pbuf.Tests.Everything.Map2Entry, map: true
  field :map3, 63, repeated: true, type: Sanity.Pbuf.Tests.Everything.Map3Entry, map: true
end

defmodule Sanity.Pbuf.Tests.Everything.Map1Entry do
  @moduledoc false
  use Protobuf, map: true, syntax: :proto3

  @type t :: %__MODULE__{
          key: String.t(),
          value: integer
        }
  defstruct [:key, :value]

  field :key, 1, type: :string
  field :value, 2, type: :int32
end

defmodule Sanity.Pbuf.Tests.Everything.Map2Entry do
  @moduledoc false
  use Protobuf, map: true, syntax: :proto3

  @type t :: %__MODULE__{
          key: integer,
          value: float
        }
  defstruct [:key, :value]

  field :key, 1, type: :int64
  field :value, 2, type: :float
end

defmodule Sanity.Pbuf.Tests.Everything.Map3Entry do
  @moduledoc false
  use Protobuf, map: true, syntax: :proto3

  @type t :: %__MODULE__{
          key: non_neg_integer,
          value: Sanity.Pbuf.Tests.Child.t()
        }
  defstruct [:key, :value]

  field :key, 1, type: :uint32
  field :value, 2, type: Sanity.Pbuf.Tests.Child
end

defmodule Sanity.Pbuf.Tests.Everything.Corpus do
  @moduledoc false
  use Protobuf, enum: true, syntax: :proto3

  field :UNIVERSAL, 0
  field :WEB, 1
  field :IMAGES, 2
  field :LOCAL, 3
  field :NEWS, 4
  field :PRODUCTS, 5
  field :VIDEO, 6
end

defmodule Sanity.Pbuf.Tests.Child do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          id: non_neg_integer,
          name: String.t()
        }
  defstruct [:id, :name]

  field :id, 1, type: :uint32
  field :name, 2, type: :string
end

defmodule Sanity.Pbuf.Tests.EverythingType do
  @moduledoc false
  use Protobuf, enum: true, syntax: :proto3

  field :EVERYTHING_TYPE_UNKNOWN, 0
  field :EVERYTHING_TYPE_SAND, 1
  field :EVERYTHING_TYPE_SPICE, 2
end
