# Blog API TypeSpec Specification

Contained in this directory is the main OpenAPI specification for both the Rails
server and the generated client that interacts with the server. The `main.tsp`
file is the source for the [generated specification][spec] that both the server
and client use.

## Installation

Install required packages with npm:

```
npm i
```

## Usage

The resulting specification gets checked into source control, which you can
regenerate at any time:

```
npm run compile
```

You can lint the generated spec using the [spectral][spectral-cli] linter:

```
npm run lint
```

> **Note**: _this will implicitly recompile your spec so you will always be linting
> the latest version._

When running in development mode, you can have the spec automatically generate
every time there is a change to `main.tsp`:

```
npm run compile:dev
```

The server will automatically pick up on these changes if it is running locally
in development mode.

[spec]: ./openapi/openapi.yaml
[spectral-cli]: https://github.com/stoplightio/spectral
