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
    def handle_cast({:test, data}, state) do
        {user_name, _amount, _currency} = data
        ExBanking.test(user_name, :test)
            |> IO.inspect()

        {:noreply, state}
    end
    def handle_cast(_msg, state) do
        {:noreply, state}
    end

    #################### External functions ####################
    def test(pid, message) do
#        :timer.sleep(1000)
        GenServer.cast(pid, message)
    end
end