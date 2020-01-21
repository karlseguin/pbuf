defmodule Sanity.Pbuf.Tests.Sub.UserStatus do
  @moduledoc false
  use Protobuf, enum: true, syntax: :proto3

  @type t :: integer | :USER_STATUS_UNKNOWN | :USER_STATUS_NORMAL | :USER_STATUS_DELETED

  field :USER_STATUS_UNKNOWN, 0
  field :USER_STATUS_NORMAL, 1
  field :USER_STATUS_DELETED, 2
end

defmodule Sanity.Pbuf.Tests.Sub.User.Name do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          first: String.t(),
          last: String.t()
        }
  defstruct [:first, :last]

  field :first, 1, type: :string
  field :last, 2, type: :string
end

defmodule Sanity.Pbuf.Tests.Sub.User do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          id: non_neg_integer,
          status: Sanity.Pbuf.Tests.Sub.UserStatus.t(),
          name: Sanity.Pbuf.Tests.Sub.User.Name.t() | nil
        }
  defstruct [:id, :status, :name]

  field :id, 1, type: :uint32
  field :status, 2, type: Sanity.Pbuf.Tests.Sub.UserStatus, enum: true
  field :name, 3, type: Sanity.Pbuf.Tests.Sub.User.Name
end
