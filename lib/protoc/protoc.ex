defmodule Pbuf.Protoc do
  @moduledoc """
  Entry point into the generator. Receives the request descriptor from stdin,
  and returns a response descriptor to stdout.
  The pupose is to generate the .pb.ex files from .proto files.
  """

  alias Pbuf.Protoc.Enumeration
  alias Google.Protobuf.Compiler
  alias Pbuf.Protoc.{Context, Template}

  @type proto_request :: Compiler.CodeGeneratorRequest.t
  @type proto_response :: Compiler.CodeGeneratorResponse.t
  @type proto_file :: Google.Protobuf.FileDescriptorProto.t
  @type proto_message :: Google.Protobuf.DescriptorProto.t
  @type proto_field :: Google.Protobuf.FieldDescriptorProto.t
  @type proto_enum :: Google.Protobuf.EnumDescriptorProto.t

  @type field :: Pbuf.Protoc.Field.t

  def main(_) do
    :io.setopts(:standard_io, encoding: :latin1)
    input = IO.binread(:all)
    request = Protobuf.Decoder.decode(input, Compiler.CodeGeneratorRequest)

   {files, err} = try do
      files = Enum.map(request.proto_file, &generate/1)
      {files, nil}
    rescue
      e -> {nil, {e, __STACKTRACE__}}
    end

    response = case err do
      nil -> Compiler.CodeGeneratorResponse.new(file: files)
      {err, st} -> Compiler.CodeGeneratorResponse.new(error: Exception.message(err) <> "\n" <> Exception.format_stacktrace(st))
    end

    IO.binwrite(Protobuf.Encoder.encode(response))
  end

  @spec generate(proto_file) :: Compiler.CodeGeneratorResponse.File.t
  defp generate(%{syntax: "proto3"} = input) do
    context = Context.new(input)

    templates = Enum.reduce(input.message_type, [], fn message, acc ->
      {context, enum} = Context.message(context, message)
      [acc, generate_message(message, enum, context)]
    end)

    templates = Enum.reduce(context.enums, templates, fn e, acc ->
      [acc, generate_enumeration(e)]
    end)

    %Compiler.CodeGeneratorResponse.File{
      insertion_point: "",
      name: String.replace(input.name, ".proto", ".pb.ex"),
      content: :erlang.iolist_to_binary(templates)
    }
  end

  defp generate(%{syntax: _unsupported}) do
    raise "This generator only supports proto3. Use https://hex.pm/packages/protobuf"
  end

  @spec generate_message(Google.Protobuf.DescriptorProto.t, %{optional(String.t) => Enumeration.t}, Context.t) :: iodata
  defp generate_message(message, enums, context) do
    fields = generate_fields(message.field, context)
    context = Context.fields(context, fields)
    Template.message(message.name, fields, enums, context)
  end

  @spec generate_fields([proto_field], Context.t) :: [{field, non_neg_integer}]
  defp generate_fields(fields, context) do
    fields
    |> Enum.map(fn f -> Pbuf.Protoc.Field.build(f, context) end)
    |> Enum.sort_by(&(&1.tag()))
  end

  @spec generate_enumeration(Enumeration.t) :: iodata
  defp generate_enumeration(e) do
    Template.enumeration(e, false)
  end

  def capitalize_first(word) do
    {char, rest} = String.Casing.titlecase_once(word, :default)
    char <> rest
  end
end
