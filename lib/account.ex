defmodule Account do
    use GenServer

    def start() do
        GenServer.start(__MODULE__, %{})
    end

    def init(state) do
        {:ok, Map.put(state, :currency_amount, [])}
    end

    #################### Call ####################
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
    def acc_test(pid) do
        GenServer.call(pid, :test)
    end

end