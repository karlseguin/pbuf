defmodule Sanity.Pbuf.Tests.Sub.User do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          id: non_neg_integer,
          status: integer
        }
  defstruct [:id, :status]

  field :id, 1, type: :uint32
  field :status, 2, type: Sanity.Pbuf.Tests.Sub.UserStatus, enum: true
end

defmodule Sanity.Pbuf.Tests.Sub.UserStatus do
  @moduledoc false
  use Protobuf, enum: true, syntax: :proto3

  field :USER_STATUS_UNKNOWN, 0
  field :USER_STATUS_NORMAL, 1
  field :USER_STATUS_DELETED, 2
end
