defmodule Account do
    use GenServer

    def start() do
        GenServer.start(__MODULE__, %{})
    end

    def init(state) do
        {:ok, Map.put(state, :currency_amount, [])}
    end

    #################### Call ####################
    def handle_call({:deposit, amount, currency}, _from, state) do
        currencies_amounts = Map.get(state, :currency_amount)
        new_amount = case List.keyfind(currencies_amounts, currency, 0) do
            {currency, current_amount} ->
                current_amount + amount
            _ ->
                amount
        end
        state1 = Map.put(state, :currency_amount, List.keyreplace(currencies_amounts, currency, 0, {currency, new_amount}))
        {:reply, {:ok, new_balance: new_amount}, state1}
    end
    def handle_call({:withdraw, amount, currency}, _from, state) do
        currencies_amounts = Map.get(state, :currency_amount)
        {reply, state1} = case List.keyfind(currencies_amounts, currency, 0) do
            {currency, current_amount} when current_amount >= amount ->
                new_amount = current_amount - amount
                {{:ok, new_balance: new_amount}, Map.put(state, :currency_amount, List.keyreplace(currencies_amounts, currency, 0, {currency, new_amount}))}
            _ ->
                {{:error, :not_enough_money}, state}
        end
        {:reply, reply, state1}
    end



    def handle_call(:test, _from, state) do

        :timer.sleep(4000)
        IO.puts("TEST FINISHED")

        {:reply, {:ok, :test}, state}
    end
    def handle_call(_msg, _from, state) do
        {:reply, :ok, state}
    end

    #################### Cast ####################
    def handle_cast(_msg, state) do
        {:noreply, state}
    end

    #################### External functions ####################
    def deposit(pid, amount, currency) do
        GenServer.call(pid, {:deposit, amount, currency})
            |> IO.inspect()
    end

    def withdraw(pid, amount, currency) do
        GenServer.call(pid, {:withdraw, amount, currency})
            |> IO.inspect()
    end



    def acc_test(pid) do
        GenServer.call(pid, :test)
    end

end