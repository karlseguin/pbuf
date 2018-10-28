defmodule Pbuf.Protoc.Enumeration do
  @moduledoc """
  Context holds information necessary for building types. The initial context
  contains file-wide information (the package name, enums). This file-wide
  context is used as the basis for message-specific contexts which include things
  which are only valid for that message (like enums defined within the message)
  """
  alias __MODULE__
  alias Pbuf.Protoc

  @enforce_keys [:name, :full_name, :values, :typespec, :default]
  defstruct @enforce_keys

  @type t :: %Enumeration{
    name: String.t,
    default: atom,
    typespec: String.t,
    full_name: String.t,
    values: %{optional(atom) => non_neg_integer}
  }

  @spec new(Protoc.proto_enum, String.t) :: t
  def new(desc, namespace) do
    {values, default} = Enum.reduce(desc.value, {%{}, 0}, fn v, {acc, default} ->
      name = String.to_atom(v.name)
      default = case v.number do
        0 -> name
        _ -> default
      end
      {Map.put(acc, name, v.number), default}
    end)

    %Enumeration{
      name: desc.name,
      values: values,
      default: default,
      full_name: namespace <> "." <> desc.name,
      typespec: ":" <> Enum.join(Map.keys(values), " | :") <> " | non_neg_integer" # ugly, but whatever
    }
  end
end
