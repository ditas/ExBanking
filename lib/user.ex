defmodule User do
    use GenServer

    def start(name) do
        GenServer.start(__MODULE__, %{})
    end

    def init(state) do
        {:ok, Map.put(state, :account, [])}
    end

    #################### Call ####################
    def handle_call({{:deposit, amount, currency}, queue}, _from, state) do

#        IO.inspect(currency)
##        :timer.sleep(4000)
#        IO.inspect(state)

        account = Map.get(state, :account)
#                  |> IO.inspect()
        {new_amount, state1} = case List.keyfind(account, currency, 0) do
            {currency, current_amount} ->
#                IO.puts("1")
                new_amount = current_amount + amount
                {new_amount, Map.put(state, :account, List.keyreplace(account, currency, 0, {currency, new_amount}))}
            _ ->
#                IO.puts("2")
                {amount, Map.put(state, :account, [{currency, amount}|account])}
        end

#        IO.inspect(new_amount)

        {:reply, {{:ok, new_balance: new_amount}, queue}, state1}
    end
    def handle_call({{:withdraw, amount, currency}, queue}, _from, state) do

#        :timer.sleep(4000)

        account = Map.get(state, :account)
        {reply, state1} = case List.keyfind(account, currency, 0) do
            {currency, current_amount} when current_amount >= amount ->
                new_amount = current_amount - amount
                {{:ok, new_balance: new_amount}, Map.put(state, :account, List.keyreplace(account, currency, 0, {currency, new_amount}))}
            _ ->
                {{:error, :not_enough_money}, state}
        end
        {:reply, {reply, queue}, state1}
    end
    def handle_call(_msg, _from, state) do
        {:reply, :ok, state}
    end

    #################### Cast ####################
#    def handle_cast({:deposit, amount, currency}, state) do
#        last_reply = Account.deposit(Map.get(state, :account), amount, currency)
#        :ets.insert(@ets_table, {Map.get(state, :name), self(), last_reply})
#        {:noreply, state}
#    end
#    def handle_cast({:withdraw, amount, currency}, state) do
#        Account.withdraw(Map.get(state, :account), amount, currency)
#        {:noreply, state}
#    end



#    def handle_cast(:test, state) do
#        Account.acc_test(Map.get(state, :account))
#        {:noreply, state}
#    end
    def handle_cast(_msg, state) do
        {:noreply, state}
    end

    #################### External functions ####################
    def execute(pid, queue) do
        [h|t] = :lists.reverse(queue)
        GenServer.call(pid, {h, t})
    end


#    def deposit(pid, amount, currency) do
#        case check_queue(pid) do
#            :ok -> GenServer.cast(pid, {:deposit, amount, currency})
#            error -> error
#        end
#    end
#
#    def withdraw(pid, amount, currency) do
#        case check_queue(pid) do
#            :ok -> GenServer.cast(pid, {:withdraw, amount, currency})
#            error -> error
#        end
#    end



#    def user_test(pid) do
#        case check_queue(pid) do
#            :ok -> GenServer.cast(pid, :test)
#            error -> error
#        end
#    end
    
    #################### Internal functions ####################
#    defp check_queue(pid) do
#        {_, q_len} = Process.info(pid, :message_queue_len)
#        case q_len + 1 <= 2 do
#            true -> :ok
#            false -> {:error, :too_many_requests_to_user}
#        end
#    end
    
end