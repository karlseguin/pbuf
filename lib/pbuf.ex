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
end
