# Rails API <=> TypeSpec <=> TypeScript Client

This is a sample project to demonstrate an end-to-end API service implementation
that relies on a shared [TypeSpec][] specification.

## Components

The project consists of 3 components:

- [API Spec][] -- The [main specification][] that defines types for both the
  server application and supports auto-generation of typed clients in any
  language that supports using the [OpenAPI][] specification. More details can
  be found in that project's [README][spec-readme].

- [Server][] -- A simple Rails API-only application that exposes endpoints for
  managing blog posts. It uses the [generated OpenAPI spec][generated-spec]
  along with the [`committee`][committee] middleware to validate incoming
  requests and, in non-production environments, outgoing responses to ensure
  they conform to the spec. See the [README][server-readme] for details.

- [Client][] -- Contains a [TypeScript][] API client that is generated from the
  [published spec][generated-spec] (using [`swagger-typescript-api`][sta]) and
  can interact with the server via a commandline interface. See the
  [README][client-readme] to get this set up.

## Running the Application

At a high-level, you can initialize the server and start it on the default port:

```
cd server && bin/setup && rails s
```

Once that is running, you can jump into the `client` directory to run the
commandline tooling:

```
cd client && yarn && yarn cli --help
```

[API Spec]: ./spec
[TypeSpec]: https://typespec.io
[main specification]: ./spec/main.tsp
[OpenAPI]: https://swagger.io/specification/
[Server]: ./server
[spec-readme]: ./spec/README.md
[committee]: https://github.com/interagent/committee
[generated-spec]: ./spec/openapi/openapi.yaml
[server-readme]: ./server/README.md
[Typescript]: https://www.typescriptlang.org/
[Client]: ./client
[sta]: https://github.com/acacode/swagger-typescript-api
[client-readme]: ./client/README.md
