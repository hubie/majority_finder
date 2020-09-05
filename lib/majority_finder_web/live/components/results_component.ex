defmodule MajorityFinderWeb.Components.ResultsComponent do
  use Phoenix.LiveComponent

  def render(assigns) do
    ~L"""
      <div phx-update="ignore" class="chart-container">
        <canvas class="results chart" id="resultsChart" phx-hook="ResultsChart"></canvas>
      </div>
    """
  end
end