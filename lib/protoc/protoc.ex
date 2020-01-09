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

  @version Pbuf.MixProject.project()[:version]

  def main(["--version"]) do
    IO.puts(@version)
  end

  def main(_args) do
    :io.setopts(:standard_io, encoding: :latin1)
    input = IO.binread(:all)
    request = Pbuf.decode!(Compiler.CodeGeneratorRequest, input)

    global = Context.Global.new()
    {files, err} = try do
      global = Enum.reduce(request.proto_file, global, fn input, global ->
        generate(input, global)
      end)
      {global.files, nil}
    rescue
      e -> {nil, {e, __STACKTRACE__}}
    end

    response = case err do
      nil -> Compiler.CodeGeneratorResponse.new(file: files)
      {err, st} -> Compiler.CodeGeneratorResponse.new(error: Exception.message(err) <> "\n" <> Exception.format_stacktrace(st))
    end

    IO.binwrite(Pbuf.encode!(response))
  end

  defp generate(%{syntax: "proto3"} = input, global) do
    {context, global} = Context.new(input, global)

    {templates, global} = Enum.reduce(input.message_type, {[], global}, fn message, {acc, global} ->
      {context, enums, global} = Context.message(context, message, global)
      generate_message(message, enums, context, acc, global)
    end)

    templates = Enum.reduce(context.enums, templates, fn {_name, e}, acc ->
      [acc, generate_enumeration(e)]
    end)

    file = %Compiler.CodeGeneratorResponse.File{
      insertion_point: "",
      name: String.replace(input.name, ".proto", ".pb.ex"),
      content: :erlang.iolist_to_binary(templates)
    }
    %{global | files: [file | global.files]}
  end

  defp generate(input, global) do
    {context, global} = Context.new(input, global)

    {templates, global} = Enum.reduce(input.message_type, {[], global}, fn message, {acc, global} ->
      {context, enum, global} = Context.message(context, message, global)
      generate_message(message, enum, context, acc, global)
    end)

    file = %Compiler.CodeGeneratorResponse.File{
      insertion_point: "",
      content: :erlang.iolist_to_binary(templates),
      name: String.replace(input.name, ".proto", ".pb.ex"),
    }
    %{global | files: [file | global.files]}
  end

  defp generate_message(message, enums, context, acc, global) do
    name = message.name
    fields = generate_fields(message.field, context)
    context = Context.fields(context, fields)
    options = Keyword.merge([json: true], parse_message_options(message.options))
    acc = [acc, trim_template(Template.message(name, fields, enums, context, options))]

    message.nested_type
    |> Enum.filter(&(&1.options == nil))
    |> Enum.reduce({acc, global}, fn message, {acc, global} ->
      context = %Context{context | namespace: context.namespace <> name <> "."}
      {context, enums, global} = Context.message(context, message, global)
      generate_message(message, enums, context, acc, global)
    end)
  end

  @spec generate_fields([proto_field], Context.t) :: [{field, non_neg_integer}]
  defp generate_fields(fields, context) do
    fields
    |> Enum.map(fn f -> Pbuf.Protoc.Field.build(f, context) end)
    |> Enum.sort_by(&(&1.tag()))
  end

  @spec generate_enumeration(Enumeration.t) :: iodata
  defp generate_enumeration(e) do
    trim_template(Template.enumeration(e, false))
  end

  defp parse_message_options(nil) do
    []
  end

  defp parse_message_options(opts) do
    [json: Map.get(opts, :json_message, 1) == 1]
  end

  def capitalize_first(word) do
    {char, rest} = String.Casing.titlecase_once(word, :default)
    char <> rest
  end

  defp trim_template(template) do
    String.replace(template, "\n\n", "\n")
  end
end
