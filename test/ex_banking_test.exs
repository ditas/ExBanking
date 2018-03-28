defmodule ExBankingTest do
  use ExUnit.Case
  doctest ExBanking

#  test "basic test" do
#      :ok = ExBanking.create_user("a")
#      assert {:error, :user_already_exists} = ExBanking.create_user("a")
#
#      assert {:ok, [new_balance: 10]} = ExBanking.deposit("a", 10, "usd")
#      assert {:ok, [new_balance: 20]} = ExBanking.deposit("a", 10, "usd")
#      assert {:ok, [new_balance: 30]} = ExBanking.deposit("a", 10, "usd")
#
#      assert {:ok, [new_balance: 20]} = ExBanking.withdraw("a", 10, "usd")
#      assert {:ok, [new_balance: 10]} = ExBanking.withdraw("a", 10, "usd")
#      assert {:error, :not_enough_money} = ExBanking.withdraw("a", 100, "usd")
#
#      assert {:error, :user_does_not_exist} = ExBanking.withdraw("b", 100, "usd")
#      assert {:error, :wrong_arguments} = ExBanking.withdraw("a", :a, "usd")
#  end

  test "check queue length" do
      ExBanking.create_user("a")
      ExBanking.create_user("b")

      {:ok, pid1} = TestProcess.start()
      {:ok, pid2} = TestProcess.start()
      {:ok, pid3} = TestProcess.start()
      {:ok, pid4} = TestProcess.start()
      {:ok, pid5} = TestProcess.start()

      TestProcess.test(pid1, {:deposit, {"a", 10, "usd"}})
      TestProcess.test(pid2, {:deposit, {"a", 10, "usd"}})
      TestProcess.test(pid3, {:deposit, {"a", 10, "usd"}})

      TestProcess.test(pid5, {:deposit, {"b", 10, "usd"}})

      TestProcess.test(pid4, {:deposit, {"a", 10, "usd"}})
  end
end
