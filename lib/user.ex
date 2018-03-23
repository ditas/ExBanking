defmodule User do
    use GenServer

    def start(name) do
#        GenServer.start(__MODULE__, %{}, name: name)
        GenServer.start(__MODULE__, %{})
    end

    def init(state) do
        {:ok, Map.put(state, :currency_amount, [])}
    end

    #################### Call ####################
    def handle_call(:test, _from, state) do

        q_len = Process.info(self(), :message_queue_len)
        IO.inspect(q_len)

        IO.puts("INCOMING CALL")

        :timer.sleep(4000)

        {:reply, {:ok, :test}, state}
    end
    def handle_call(_msg, _from, state) do
        {:reply, :ok, state}
    end

    #################### Cast ####################
    def handle_cast(:test, state) do

        q_len = Process.info(self(), :message_queue_len)
        IO.inspect(q_len)

        IO.puts("INCOMING CAST")

        :timer.sleep(4000)

        {:noreply, state}
    end
    def handle_cast(_msg, state) do
        {:noreply, state}
    end

    #################### External functions ####################
    def user_test(pid) do
#        {:message_queue_len, q_len} = Process.info(pid, :message_queue_len)
#        IO.inspect(q_len)

#        case q_len + 1 < 2 do
#            true -> IO.puts("OK")
#            false -> IO.puts("NOT OK")
#        end

#        GenServer.call(pid, :test)
        GenServer.cast(pid, :test)
    end

end