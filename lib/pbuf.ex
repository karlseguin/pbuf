defmodule Pbuf do
  @spec encode!(struct) :: binary
  def encode!(struct) do
    struct.__struct__.encode!(struct)
  end

  @spec encode_to_iodata!(struct) :: iodata
  def encode_to_iodata!(struct) do
    struct.__struct__.encode_to_iodata!(struct)
  end

  defdelegate decode(module, iodata), to: Pbuf.Decoder
  defdelegate decode!(module, iodata), to: Pbuf.Decoder

  def glue_length(_tag, nil) do
    []
  end

  def glue_length(tag, value) do
    use Bitwise, only_operators: true

    size = value
    |> byte_size()
    |> Pbuf.Encoder.varint()

    [Pbuf.Encoder.varint(tag <<< 3 ||| 2), size, value]
  end
end
