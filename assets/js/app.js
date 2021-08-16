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
import * as Bowser from './browser.js'

function getAnimId(){ return Math.floor(Math.random() * 100000) }

const browser = Bowser.getParser(window.navigator.userAgent)
document.body.classList.add(browser.parsedResult.browser.name)

// Fullscreen request on first interaction
// const requestFullScreen = () => {
//   document.documentElement.requestFullscreen({ navigationUI: 'hide' })
//   document.removeEventListener('click', requestFullScreen)
// }
// document.addEventListener('click', requestFullScreen)


let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
let liveSocket = new LiveSocket("/live", Socket, {
  params: {_csrf_token: csrfToken},
  dom: {
    onBeforeElUpdated(from, to){
      if(from.__x){window.Alpine.clone(from.__x, to)}
      if (to.classList.contains("animate-update")) {
        if (from.textContent !== to.textContent) {
          const id = `animated-${getAnimId()}`
          to.classList.add("live_view_updated")
          to.classList.add(id)
          setTimeout(() => {
            const node = document.querySelector(`.${id}`)
            node.classList.remove("live_view_updated")
            node.classList.remove(id)
          }, 600)
        }
      }

      if (to.classList.contains("list-animate")) {
        const fromRow = +from.dataset['row']
        const toRow = +to.dataset['row']
        if (fromRow !== toRow) {
          const id =`animated-${getAnimId()}`
          to.classList.add(id)
          const dy = 50 * (fromRow - toRow)
          to.style.transform = `translateY(${dy}px)`
          to.style.transition = 'transform 0s'
          to.style.zIndex = fromRow
          to.style.backgroundColor = 'white';
          setTimeout(() => {
            const node = document.querySelector(`.${id}`)
            node.classList.remove(id)
            node.style.borderTop = '1px solid black';
            node.style.transform = '';
            node.style.transition = 'all .5s';
            setTimeout(() => {
              node.style = {}
            }, 450)
          }, 600)
        }
      }
    }
  }
})

// Show progress bar on live navigation and form submits
window.addEventListener("phx:page-loading-start", info => NProgress.start())
window.addEventListener("phx:page-loading-stop", info => NProgress.done())

// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(3000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket
