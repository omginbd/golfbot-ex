const esbuild = require('esbuild')
const sassPlugin = require('esbuild-plugin-sass')
const ncp = require('ncp')

const logLevel = process.env.ESBUILD_LOG_LEVEL || 'silent'
const watch = !!process.env.ESBUILD_WATCH

const plugins = [
  sassPlugin()
]

const promise = esbuild.build({
  entryPoints: ['js/app.js'],
  bundle: true,
  target: 'es2016',
  plugins,
  outdir: '../priv/static',
  logLevel,
  watch
}).then(() => {
  ncp('./static', '../priv/static/', (err) => err && console.error(err))
})

if (watch) {
  promise.then(_result => {
    process.stdin.on('close', () => {
      process.exit(0)
    })
    process.stdin.resume()
  })
}
