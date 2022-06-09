// We import the CSS which is extracted to its own file by esbuild.
// Remove this line if you add a your own CSS build pipeline (e.g postcss).

// If you want to use Phoenix channels, run `mix help phx.gen.channel`
// to get started and then uncomment the line below.
// import "./user_socket.js"

// You can include dependencies in two ways.
//
// The simplest option is to put them in assets/vendor and
// import them using relative paths:
//
//     import "../vendor/some-package.js"
//
// Alternatively, you can `npm install some-package --prefix assets` and import
// them using a path starting with the package name:
//
//     import "some-package"
//

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html"
import {Socket} from "phoenix"
import {LiveSocket} from "phoenix_live_view"
import topbar from '../vendor/topbar.js'
import * as Browser from './browser.js'
import Scorer from './scorer.js'
import localforage from './localforage.js'

window.localforage = localforage

function getAnimId(){ return Math.floor(Math.random() * 100000) }

const browser = Browser.getParser(window.navigator.userAgent)
document.body.classList.add(browser.parsedResult.browser.name)

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
let liveSocket = new LiveSocket("/live", Socket, {
  params: {_csrf_token: csrfToken},
  hooks: { Scorer },
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
let progressTimeout
window.addEventListener('phx:page-loading-start', () => { clearTimeout(progressTimeout); progressTimeout = setTimeout(topbar.show, 100) })
window.addEventListener('phx:page-loading-stop', () => { clearTimeout(progressTimeout); topbar.hide() })

// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(3000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket
