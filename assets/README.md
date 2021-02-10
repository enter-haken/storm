# assets

The `assets` folder contains all necessary client related code
When you build `storm` the `deploy` target of the `package.json` is invoked.

## css

The `sass-loader` will build the `bulma` css styles used by `storm`.
Currently there are no custom styles used.

The resulting `app.css` file will be copied to `priv/static/css`

## javascript

Javascript files will be combined into one `app.js` and will be copied to `priv/static/js`

## static files

Static files will be copied to `priv/static`
