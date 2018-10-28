defmodule Pbuf.Tests.Decode do
  use Pbuf.Tests.Base

  alias Pbuf.Decoder.Error
  alias Pbuf.Tests.Everything

  test "error for wrong type" do
    assert {:error, %Error{} = err} = Everything.decode(<<9, 10>>)
    assert err.tag == 1
    assert err.module == Everything
    assert err.message == "Elixir.Pbuf.Tests.Everything tag 1 has an incorrect write type of 1"
  end

  test "ignores unknown fields" do
    assert {:ok, _everything} = Everything.decode(<<210, 10>>)
    assert Everything.decode!(<<210, 10>>) == %Everything{}
  end

  test "error on unexpected map data" do
    assert {:error, %Error{} = err} = Everything.decode(<<234, 3, 2, 1, 2, 3, 4>>)
    assert err.tag == 61
    assert err.module == Everything
    assert err.message == "Elixir.Pbuf.Tests.Everything.map1 tag 61 unexpected map data: <<2>>"

    assert_raise Pbuf.Decoder.Error, "Elixir.Pbuf.Tests.Everything.map1 tag 61 unexpected map data: <<2>>", fn ->
      Everything.decode!(<<234, 3, 2, 1, 2, 3, 4>>)
    end
  end
end
