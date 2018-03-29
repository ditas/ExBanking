# ExBanking

### How to use

```elixir
iex -S mix

ExBanking.create_user("a")
ExBanking.create_user("b")

ExBanking.deposit("a", 100, "usd")
ExBanking.withdraw("a", 50, "usd")
ExBanking.send("a", "b", 40, "usd")
```
### Test

```elixir
mix test
```

### Notes

You can use ExBanking API's functions on the same/another user simultaneously from different external processes.

Check "check queue length" test from ExBankingTest module for details.