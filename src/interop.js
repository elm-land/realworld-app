// This returns the flags passed into your Elm application
export const flags = async ({ env }) => {
  var flags = {
    user: JSON.parse(localStorage.getItem('user')) || null
  }

  return flags
}

// This function is called once your Elm app is running
export const onReady = ({ app }) => {
  // https://guide.elm-lang.org/interop/ports.html
  app.ports.outgoing.subscribe(({ tag, data }) => {
    switch (tag) {
      case 'saveUser':
        return localStorage.setItem('user', JSON.stringify(data))
      case 'clearUser':
        return localStorage.removeItem('user')
      default:
        return console.warn(`Unrecognized Port`, tag)
    }
  })
}