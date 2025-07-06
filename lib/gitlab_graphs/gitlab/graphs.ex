defmodule GitlabGraphs.Gitlab.Graphs do
    def get_graph_data(_key) do
      {:ok, [:graph, :data]}
    end
end
