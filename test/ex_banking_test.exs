defmodule ExBankingTest do
    use ExUnit.Case
    doctest ExBanking

#    test "basic test" do
#        :ok = ExBanking.create_user("a")
#
#        assert {:ok, :bla_bla} = ExBanking.test("a", :test)
#        assert {:ok, :bla_bla} = ExBanking.test("a", :test)
#    end

    test "basic test 1" do
        :ok = ExBanking.create_user("b")
        assert {:error, :user_already_exists} = ExBanking.create_user("b")

        assert {:ok, [new_balance: 10]} = ExBanking.deposit("b", 10, "usd")
        assert {:ok, [new_balance: 20]} = ExBanking.deposit("b", 10, "usd")

        assert {:ok, [new_balance: 10]} = ExBanking.withdraw("b", 10, "usd")
        assert {:ok, [new_balance: 0]} = ExBanking.withdraw("b", 10, "usd")
        assert {:error, :not_enough_money} = ExBanking.withdraw("b", 10, "usd")
    end

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
        ExBanking.create_user("x")
        ExBanking.create_user("z")

        {:ok, pid1} = TestProcess.start()
        {:ok, pid2} = TestProcess.start()
        {:ok, pid3} = TestProcess.start()
        {:ok, pid4} = TestProcess.start()
        {:ok, pid5} = TestProcess.start()

        TestProcess.test(pid1, {:test, {"x", 10, "usd"}})
        TestProcess.test(pid2, {:test, {"x", 10, "usd"}})
        TestProcess.test(pid3, {:test, {"x", 10, "usd"}})

#        TestProcess.test(pid5, {:test, {"z", 10, "usd"}})

        TestProcess.test(pid4, {:test, {"x", 10, "usd"}})

        :timer.sleep(1000)
#        ExBanking.clear()
    end
end
