# RealWorld Example App

> ### A codebase containing real world examples (CRUD, auth, advanced patterns, etc) that adheres to the [RealWorld](https://github.com/gothinkster/realworld) spec and API.

<!-- ### [Demo](https://realworld.elm.land/)&nbsp;&nbsp;&nbsp;&nbsp;[RealWorld](https://github.com/gothinkster/realworld) -->

This codebase was created to demonstrate using [elm-open-api](https://www.npmjs.com/package/elm-open-api) for all API operations.

This codebase is forked from the [Elm Land RealWorld app](https://github.com/elm-land/realworld-app) to provide an easy to compare diff of hand writting the API vs generating it from an [OpenAPI](https://www.openapis.org/) spec.

For more information on how to this works with other frontends/backends, head over to the [RealWorld](https://github.com/gothinkster/realworld) repo.

# How it works

> The file `Api.elm` is generated from the OpenAPI spec `./openapi.yml` using [elm-open-api](https://www.npmjs.com/package/elm-open-api), then used within the rest of the application.

This application was built with [Elm Land](https://elm.land), a production-ready framework for building Elm applications.

Check out the [the source code](./src) to get a feel for the project structure!

```
openapi.yml
generate/
  Api.elm
src/
  Api/...
  Components/...
  Pages/...
  Utils/...
  Shared.elm
  Ports.elm
```

# Getting started

```
npm install
npm run gen-api
npm run dev
```
