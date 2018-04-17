defmodule User do
    use GenServer

    def start() do
        GenServer.start(__MODULE__, %{})
    end

    def init(state) do
        {:ok, Map.put(state, :account, [])}
    end

    #################### Call ####################
    def handle_call({:deposit, amount, currency}, _from, state) do

#        :timer.sleep(3000)

        account = Map.get(state, :account)
        {new_amount, state1} = case List.keyfind(account, currency, 0) do
            {currency, current_amount} ->
                new_amount = current_amount + amount
                {new_amount, Map.put(state, :account, List.keyreplace(account, currency, 0, {currency, new_amount}))}
            _ ->
                {amount, Map.put(state, :account, [{currency, amount}|account])}
        end
        {:reply, {:ok, new_balance: new_amount}, state1}
    end
    def handle_call({:withdraw, amount, currency}, _from, state) do

#        :timer.sleep(3000)

        account = Map.get(state, :account)
        {reply, state1} = case List.keyfind(account, currency, 0) do
            {currency, current_amount} when current_amount >= amount ->
                new_amount = current_amount - amount
                {{:ok, new_balance: new_amount}, Map.put(state, :account, List.keyreplace(account, currency, 0, {currency, new_amount}))}
            _ ->
                {{:error, :not_enough_money}, state}
        end
        {:reply, reply, state1}
    end
    def handle_call({:get_balance, currency}, _from, state) do
        account = Map.get(state, :account)
        reply = case List.keyfind(account, currency, 0) do
            {_currency, current_amount} ->
                {:ok, balance: current_amount}
            _ ->
                {:error, :wrong_arguments}
        end
        {:reply, reply, state}
    end
    def handle_call(_msg, _from, state) do
        {:reply, :ok, state}
    end

    #################### Cast ####################
    def handle_cast({{:deposit, amount, currency}, from, client, ref}, state) do
        account = Map.get(state, :account)
        {new_amount, state1} = case List.keyfind(account, currency, 0) do
            {currency, current_amount} ->
                new_amount = current_amount + amount
                {new_amount, Map.put(state, :account, List.keyreplace(account, currency, 0, {currency, new_amount}))}
            _ ->
                {amount, Map.put(state, :account, [{currency, amount}|account])}
        end

        GenServer.cast(from, {:user_reply, {:ok, [new_balance: new_amount]}, client, ref})
        {:noreply, state1}
    end
    def handle_cast({{:withdraw, amount, currency}, from, client, ref}, state) do
        account = Map.get(state, :account)
        {reply, state1} = case List.keyfind(account, currency, 0) do
            {currency, current_amount} when current_amount >= amount ->
                new_amount = current_amount - amount
                {{:ok, new_balance: new_amount}, Map.put(state, :account, List.keyreplace(account, currency, 0, {currency, new_amount}))}
            _ ->
                {{:error, :not_enough_money}, state}
        end

        GenServer.cast(from, {:user_reply, reply, client, ref})
        {:noreply, state1}
    end
    def handle_cast({:test, from, client, ref}, state) do
        :timer.sleep(4000)

        GenServer.cast(from, {:user_reply, {:ok, :bla_bla}, client, ref})
        {:noreply, state}
    end
    def handle_cast(_msg, state) do
        {:noreply, state}
    end

    #################### External functions ####################
    def execute(pid, message) do
        GenServer.cast(pid, message)
    end
end