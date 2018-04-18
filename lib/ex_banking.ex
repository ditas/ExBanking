defmodule ExBanking do
    use GenServer

    @ets_table :users

    def start_link() do
        GenServer.start_link(__MODULE__, [], name: __MODULE__)
    end

    def init(_) do
        @ets_table = :ets.new(@ets_table, [:set, :public, :named_table])
        {:ok, []}
    end

    #################### Call ####################
    def handle_call(_msg, _from, state) do
        {:reply, :ok, state}
    end

    #################### Cast ####################
    def handle_cast(_msg, state) do
        {:noreply, state}
    end

    #################### External functions ####################
    def create_user(user_name) when is_bitstring(user_name) do
        case :ets.lookup(@ets_table, user_name) do
            [{user_name, pid}|_] when pid != :undefined ->
                {:error, :user_already_exists}
            _ ->
                try do
                    {:ok, pid} = EBQueue.start(user_name)
                    Process.monitor(pid)
                    :ets.insert(@ets_table, {user_name, pid})
                    :ok
                rescue
                    e in ArgumentError -> {:error, e}
                end
        end
    end
    def create_user(_user_name) do
        {:error, :wrong_arguments}
    end

    def test(user_name, message) do
        try_execute(user_name, message)
    end

    def deposit(user_name, amount, currency) when is_number(amount) and (amount >= 0) do
        try_execute(user_name, {:deposit, int_precision(amount), currency})
    end
    def deposit(_user_name, _amount, _currency) do
        {:error, :wrong_arguments}
    end

    def withdraw(user_name, amount, currency) when is_number(amount) and (amount >= 0) do
        try_execute(user_name, {:withdraw, int_precision(amount), currency})
    end
    def withdraw(_user_name, _amount, _currency) do
        {:error, :wrong_arguments}
    end

    def get_balance(user_name, currency) do
        try_execute(user_name, {:get_balance, currency})
    end

    def send(from_user, to_user, amount, currency) when is_number(amount) and (amount >= 0) do
        do_send(from_user, to_user, int_precision(amount), currency)
#            |> IO.inspect()
    end
    def send(_from_user, _to_user, _amount, _currency) do
        {:error, :wrong_arguments}
    end

    #################### Internal functions ####################
    defp try_execute(user_name, message) do
        case :ets.lookup(@ets_table, user_name) do
            [{user_name, pid}|_] when pid != :undefined ->
                GenServer.call(pid, message)
            _ ->
                {:error, :user_does_not_exist}
        end
    end

    defp do_send(from_user, to_user, amount, currency) do
        case :ets.lookup(@ets_table, from_user) do
            [{from_user, from_pid}|_] when from_pid != :undefined ->
                case :ets.lookup(@ets_table, to_user) do
                    [{to_user, to_pid}|_] when to_pid != :undefined ->
                        case GenServer.call(from_pid, {:withdraw, amount, currency}) do
                            {:ok, [new_balance: from_balance]} ->
                                case GenServer.call(to_pid, {:deposit, amount, currency}) do
                                    {:ok, [new_balance: to_balance]} ->
                                        {:ok, from_user_balance: from_balance, to_user_balance: to_balance}
                                    {:error, :too_many_requests_to_user} ->
                                        {:error, :too_many_requests_to_receiver}
                                    error ->
                                        error
                                end
                            {:error, :too_many_requests_to_user} ->
                                {:error, :too_many_requests_to_sender}
                            error ->
                                error
                        end
                    _ ->
                        {:error, :receiver_does_not_exist}
                end
            _ ->
                {:error, :sender_does_not_exist}
        end
    end

    defp int_precision(number) do
        round(number * 100)
    end

end