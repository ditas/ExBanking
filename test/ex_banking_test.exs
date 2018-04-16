defmodule ExBankingTest do
    use ExUnit.Case
    doctest ExBanking

#    test "basic test" do
#        :ok = ExBanking.create_user("a")
#        assert {:error, :user_already_exists} = ExBanking.create_user("a")
#
#        assert {:ok, [new_balance: 10.0]} = ExBanking.deposit("a", 10, "usd")
#        assert {:ok, [new_balance: 20.0]} = ExBanking.deposit("a", 10, "usd")
#        assert {:ok, [new_balance: 30.0]} = ExBanking.deposit("a", 10, "usd")
#
#        assert {:ok, [new_balance: 20.0]} = ExBanking.withdraw("a", 10, "usd")
#        assert {:ok, [new_balance: 10.0]} = ExBanking.withdraw("a", 10, "usd")
#        assert {:error, :not_enough_money} = ExBanking.withdraw("a", 100, "usd")
#
#        assert {:error, :user_does_not_exist} = ExBanking.withdraw("b", 100, "usd")
#        assert {:error, :wrong_arguments} = ExBanking.withdraw("a", :a, "usd")
#
#        ExBanking.clear()
#
#        :timer.sleep(1000)
#    end
#
#    test "send test" do
#        :ok = ExBanking.create_user("a")
#        :ok = ExBanking.create_user("b")
#
#        assert {:ok, [new_balance: 100.0]} = ExBanking.deposit("a", 100, "usd")
#        assert {:ok, [new_balance: 10.0]} = ExBanking.deposit("b", 10, "usd")
#
#        assert {:ok, [from_user_balance: 10.0, to_user_balance: 100.0]} = ExBanking.send("a", "b", 90, "usd")
#        assert {:error, :not_enough_money} = ExBanking.send("a", "b", 90, "usd")
#        assert {:error, :sender_does_not_exist} = ExBanking.send("c", "b", 90, "usd")
#        assert {:error, :receiver_does_not_exist} = ExBanking.send("a", "c", 90, "usd")
#
#        ExBanking.clear()
#
#        :timer.sleep(1000)
#    end

    # This is not a real unit test. It shows the error if length exceeds
    test "check queue length" do
        ExBanking.create_user("a")
        ExBanking.create_user("b")

        {:ok, pid1} = TestProcess.start()
        {:ok, pid2} = TestProcess.start()
        {:ok, pid3} = TestProcess.start()
        {:ok, pid4} = TestProcess.start()
        {:ok, pid5} = TestProcess.start()

        TestProcess.test(pid1, {:test, {"a", 10, "usd"}})
        TestProcess.test(pid2, {:test, {"a", 10, "usd"}})
        TestProcess.test(pid3, {:test, {"a", 10, "usd"}})

#        TestProcess.test(pid5, {:test, {"b", 10, "usd"}})

        TestProcess.test(pid4, {:test, {"a", 10, "usd"}})

        :timer.sleep(1000)
#        ExBanking.clear()
    end
end
