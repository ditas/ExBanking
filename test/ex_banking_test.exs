defmodule ExBankingTest do
  use ExUnit.Case
  doctest ExBanking

  test "basic test" do
      :ok = ExBanking.create_user("a")

      assert {:ok, [new_balance: 10]} = ExBanking.deposit("a", 10, "usd")
      assert {:ok, [new_balance: 20]} = ExBanking.deposit("a", 10, "usd")
      assert {:ok, [new_balance: 30]} = ExBanking.deposit("a", 10, "usd")

      assert {:ok, [new_balance: 20]} = ExBanking.withdraw("a", 10, "usd")
      assert {:ok, [new_balance: 10]} = ExBanking.withdraw("a", 10, "usd")
      assert {:error, :not_enough_money} = ExBanking.withdraw("a", 100, "usd")
  end

  test "check queue length" do

  end
end
