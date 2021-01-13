// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import "../css/app.scss"

// webpack automatically bundles all modules in your
// entry points. Those entry points can be configured
// in "webpack.config.js".
//
// Import deps with the dep name or local files with a relative path, for example:
//
//     import {Socket} from "phoenix"
//     import socket from "./socket"
//
import "phoenix_html"
import {Socket} from "phoenix"
import NProgress from "nprogress"
import {LiveSocket} from "phoenix_live_view"
// import adapter from 'webrtc-adapter';


require("chartkick")
require("chart.js")
var TimerClass = require("easytimer.js").Timer
var timer = new TimerClass();


function updateTimerValue() {
  var s= document.getElementById('countdownTimer')
  s.innerHTML = timer.getTimeValues().toString(['minutes', 'seconds']);
}

let Hooks = {}
Hooks.Timer = {

  mounted() {
    timer.addEventListener('secondsUpdated', function (e) {
      updateTimerValue()
    });
    this.handleEvent("no_timer", ({data}) => {
        timer.stop()
        // updateTimerValue()
      }
    )
    this.handleEvent("new_timer", ({data}) => {
        timer.stop()
        timer.start({countdown: true, startValues: {seconds: data}});
        updateTimerValue()
      }
    )
  }
}
Hooks.ResultsChart = {
  mounted() {

    var ctx = document.getElementById('resultsChart');
    Chart.defaults.global.defaultFontFamily='Montserrat, sans-serif'
    var resultsChart = new Chart(ctx, {
        type: 'bar',
        data: {
            // labels: ['Red', 'Blue', 'Yellow', 'Green', 'Purple', 'Orange'],
            datasets: [{
                // label: '# of Votes',
                // data: [12, 19, 3, 5, 2, 3],
                backgroundColor: [
                    'rgb(242,188,35)',
                    'rgb(242,188,35)',
                    'rgb(242,188,35)',
                    'rgb(242,188,35)',
                    'rgb(242,188,35)',
                    'rgb(242,188,35)'
                ],
                borderColor: [
                    'rgb(242,188,35)',
                    'rgb(242,188,35)',
                    'rgb(242,188,35)',
                    'rgb(242,188,35)',
                    'rgb(242,188,35)',
                    'rgb(242,188,35)'
                ],
                borderWidth: 1
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            legend: {
              display: false
            },
            scales: {
                yAxes: [{
                    ticks: {
                        fontSize: 30,
                        beginAtZero: true,
                        precision: 0
                    }
                }],
                xAxes: [{
                  color: 'rbga(1,1,1,1)',
                  ticks: {
                    fontSize: 30,
                    fontColor: 'rgb(242,188,35)',
                    fontStyle: 'bold',
                    callback: function(label, index, labels) {
                                if (/\s/.test(label)) {
                                    return label.split(" ");
                                } else {
                                    return label;
                                }
                            }
                        }
                }]
            }
        }
    });

    this.handleEvent("new_results", ({data}) => {
        console.log(data)
        // resultsChart.data.labels = Object.keys(data)
        var labels = []
        var values = []
        data.forEach((lineitem) => {
            labels.push(Object.keys(lineitem))
            values.push(Object.values(lineitem))
        })

        resultsChart.data.datasets[0].data = [].concat.apply([], values)
        resultsChart.data.labels = [].concat.apply([], labels)

        resultsChart.update();
      }
    )
  }
}

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
let liveSocket = new LiveSocket("/live", Socket, {hooks: Hooks, params: {_csrf_token: csrfToken}})

// Show progress bar on live navigation and form submits
window.addEventListener("phx:page-loading-start", info => NProgress.start())
window.addEventListener("phx:page-loading-stop", info => NProgress.done())

// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)
window.liveSocket = liveSocket
