%{
  configs: [%{
    name: "default",
      files: %{included: ["lib/"]}, color: true,
      checks: [
        {Credo.Check.Design.TagTODO, false},
        {Credo.Check.Readability.AliasOrder, false},
        {Credo.Check.Refactor.Nesting, max_nesting: 3},
        {Credo.Check.Readability.ModuleDoc, ignore_names: ~r//},
        {Credo.Check.Readability.ParenthesesOnZeroArityDefs, false},
        {Credo.Check.Refactor.LongQuoteBlocks, max_line_count: 500},
        {Credo.Check.Design.AliasUsage, if_called_more_often_than: 1, if_nested_deeper_than: 2},
        {Credo.Check.Readability.MaxLineLength, priority: :low, max_length: 10_000},
      ]
    }
  ]
}

