defmodule User do
    use GenServer

    def start(name) do
#        GenServer.start(__MODULE__, %{}, name: name)
        GenServer.start(__MODULE__, %{})
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
    def handle_cast(:test, state) do

#        :timer.sleep(4000)
#        IO.puts("TEST FINISHED")
        Account.acc_test(Map.get(state, :account))

        {:noreply, state}
    end
    def handle_cast(_msg, state) do
        {:noreply, state}
    end

    #################### External functions ####################
    def user_test(pid) do
        GenServer.cast(pid, :test)
    end

end