defmodule User do
    use GenServer

    @ets_table :users

    def start(name) do
        GenServer.start(__MODULE__, %{:name => name})
    end

    def init(state) do
        {:ok, acc_pid} = Account.start()
        {:ok, Map.put(state, :account, acc_pid)}
    end

    #################### Call ####################
    def handle_call(_msg, _from, state) do
        {:reply, :ok, state}
    end

    #################### Cast ####################
    def handle_cast({:deposit, amount, currency}, state) do
        last_reply = Account.deposit(Map.get(state, :account), amount, currency)
        :ets.insert(@ets_table, {Map.get(state, :name), self(), last_reply})
        {:noreply, state}
    end
    def handle_cast({:withdraw, amount, currency}, state) do
        Account.withdraw(Map.get(state, :account), amount, currency)
        {:noreply, state}
    end



    def handle_cast(:test, state) do
        Account.acc_test(Map.get(state, :account))
        {:noreply, state}
    end
    def handle_cast(_msg, state) do
        {:noreply, state}
    end

    #################### External functions ####################
    def deposit(pid, amount, currency) do
        case check_queue(pid) do
            :ok -> GenServer.cast(pid, {:deposit, amount, currency})
            error -> error
        end
    end

    def withdraw(pid, amount, currency) do
        case check_queue(pid) do
            :ok -> GenServer.cast(pid, {:withdraw, amount, currency})
            error -> error
        end
    end



    def user_test(pid) do
        case check_queue(pid) do
            :ok -> GenServer.cast(pid, :test)
            error -> error
        end
    end
    
    #################### Internal functions ####################
    defp check_queue(pid) do
        {_, q_len} = Process.info(pid, :message_queue_len)
        case q_len + 1 <= 2 do
            true -> :ok
            false -> {:error, :too_many_requests_to_user}
        end
    end
    
end