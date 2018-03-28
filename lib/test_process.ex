defmodule TestProcess do
    use GenServer

    def start() do
        GenServer.start(__MODULE__, %{})
    end

    def init(state) do
        {:ok, state}
    end

    #################### Call ####################
    def handle_call(_msg, _from, state) do
        {:reply, :ok, state}
    end

    #################### Cast ####################
    def handle_cast({:deposit, data}, state) do
        {user_name, amount, currency} = data

#        {:ok, [new_balance: _balance]} = ExBanking.deposit(user_name, amount, currency)
        ExBanking.deposit(user_name, amount, currency)
            |> IO.inspect()

        {:noreply, state}
    end
    def handle_cast(_msg, state) do
        {:noreply, state}
    end

    #################### External functions ####################
    def test(pid, message) do
        :timer.sleep(1000)
        GenServer.cast(pid, message)
    end
end