defmodule Pbuf.Protoc.OneOf do
  @moduledoc """
  This is the 'parent' of OneOfs. It acts as both configuration via the context
  and as a pseudo Field when rendering the template.
  """
  alias __MODULE__
  alias Pbuf.Protoc.Field

  @enforce_keys [:name, :typespec, :default]
  defstruct @enforce_keys

  @type t :: %OneOf{
    name: String.t,

    # Initially we only know the name and the possible values come later as
    # we parse the data. This is a map of the one of label to its type and prefix
    typespec: String.t,

    default: String.t # always "nil"
  }

  @spec new(String.t) :: t
  def new(name) do
    %OneOf{name: name, typespec: "map", default: "nil"}
  end

  @spec add(t, Field.t) :: t
  def add(%{typespec: existing} = oneof, field) do
    %OneOf{oneof | typespec: existing <> " | " <> build_typespec(field)}
  end

  defp build_typespec(field) do
    "{:#{field.name}, #{field.typespec}}"
  end
end
