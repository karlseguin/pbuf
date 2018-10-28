defmodule Pbuf.Protoc.Context do
  @moduledoc """
  Context holds information necessary for building types. The initial context
  contains file-wide information (the package name, enums). This file-wide
  context is used as the basis for message-specific contexts which include things
  which are only valid for that message (like enums defined within the message)
  """
  alias __MODULE__
  alias Pbuf.Protoc
  alias Pbuf.Protoc.{OneOf, Enumeration}

  @enforce_keys [:package, :namespace, :enums, :maps, :oneofs, :version]
  defstruct @enforce_keys

  @type t :: %Context{
    version: 2 | 3,

    # The package as presented in the .proto file. We keep this around because
    # references within the description use it everywhere. When looking for an
    # enumeration (and maybe more) we can just use the reference as-is for our
    # lookup, rather than having to convert it to the proper elixir namespace
    package: String.t,

    # The package converted to a Elixir namespace (pascal case)
    namespace: String.t,

    # Map name to {key type, value type}
    maps: %{optional(String.t) => {any, any}},

    # Enumertions in this file (initially global, then type-embedded)
    enums: [Enumeration.t],

    # OneOf index to our OneOf type
    oneofs: %{optional(non_neg_integer) => OneOf.t}
  }

  @spec new(Protoc.proto_file) :: t
  def new(%{package: package} = input) do
    %Context{
      maps: %{},    # only exists at the message level
      oneofs: %{},  # only exists at the message level
      package: package,
      namespace: namespace(package),
      version: version(input.syntax),
      enums: extract_enums(input.enum_type, package)
    }
  end

  # Expand the file context with message-specific information
  @spec message(t, Protoc.proto_message) :: {t, %{optional(String.t) => Enumeration.t}}
  def message(context, desc) do
    package = context.package <> "." <> desc.name
    enums = extract_enums(desc.enum_type, package)
    context = %Context{context |
      maps: maps(desc),
      oneofs: oneofs(desc),
      enums: enums ++ context.enums,
    }
    {context, enums}
  end

  # Expand the message-specific context with additional field information. This
  # is needed to finish loading up our oneof information.
  @spec fields(t, [any]) :: t
  def fields(context, fields) do
    oneofs = context.oneofs

    oneofs = Enum.reduce(fields, oneofs, fn %{oneof_index: index} = field, oneofs ->
      case index == nil do
        true -> oneofs
        false ->
          oneof = Map.get(oneofs, index)
          Map.put(oneofs, index, OneOf.add(oneof, field))
      end
    end)

    %Context{context | oneofs: oneofs}
  end


  defp version("proto3") do
    3
  end

  defp version(_) do
    2
  end

  @spec namespace(String.t) :: String.t
  defp namespace(package) do
    package
    |> String.split(".")
    |> Enum.map(&Protoc.capitalize_first/1)
    |> Enum.join(".")
  end

  defp extract_enums(values, package) do
    namespace = namespace(package)
    Enum.reduce(values, [], fn v, acc ->
      e = Enumeration.new(v, namespace)
      [e | acc]
    end)
  end

  defp maps(desc) do
    desc.nested_type
    |> Enum.filter(&(&1.options))
    |> Enum.reduce(%{}, fn type, maps ->
      case type.options.map_entry do
        false -> maps
        true ->
          {key_field, value_field} = extract_map_info(type.field)
          Map.put(maps, type.name, {key_field, value_field})
      end
    end)
  end

  defp extract_map_info([a, b]) do
   case a.name == "key" do
      true -> {a, b}
      false -> {b, a}
    end
  end

  defp oneofs(desc) do
    desc.oneof_decl
    |> Enum.with_index()
    |> Enum.into(%{}, fn {oneof, index} ->
      {index, OneOf.new(oneof.name)}
    end)
  end

end
