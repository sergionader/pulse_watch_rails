import { Controller } from "@hotwired/stimulus"
import "chart.js/auto"

export default class extends Controller {
  static values = { url: String }
  static targets = ["canvas"]

  connect() {
    this.loadChart()
  }

  disconnect() {
    if (this.chart) {
      this.chart.destroy()
    }
  }

  async loadChart() {
    const response = await fetch(this.urlValue)
    const data = await response.json()

    if (data.length === 0) {
      this.canvasTarget.parentElement.innerHTML = '<p class="text-sm text-gray-500 text-center py-8">No check data available yet.</p>'
      return
    }

    const labels = data.map(d => new Date(d.time).toLocaleTimeString())
    const responseTimes = data.map(d => d.response_time_ms)
    const colors = data.map(d => d.successful ? "rgba(34, 197, 94, 0.8)" : "rgba(239, 68, 68, 0.8)")

    const Chart = (await import("chart.js/auto")).default

    this.chart = new Chart(this.canvasTarget, {
      type: "line",
      data: {
        labels,
        datasets: [{
          label: "Response Time (ms)",
          data: responseTimes,
          borderColor: "rgb(99, 102, 241)",
          backgroundColor: "rgba(99, 102, 241, 0.1)",
          pointBackgroundColor: colors,
          pointBorderColor: colors,
          fill: true,
          tension: 0.3
        }]
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        plugins: {
          legend: { display: false }
        },
        scales: {
          y: {
            beginAtZero: true,
            title: { display: true, text: "ms" }
          },
          x: {
            ticks: { maxTicksLimit: 12 }
          }
        }
      }
    })
  }
}
