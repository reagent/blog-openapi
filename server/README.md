# Example Blogging API Server

This is an example API for managing posts to a fictitious blog -- all requests
and responses are validated against a [generated OpenAPI spec][generated-spec]
found in the root-level `spec` directory.

We use [committee][] to validate both inbound and, in non-production
environments, outbound API requests against the published spec. To see how the
spec is maintained, check out the [associated README][spec-readme].

## Running the Application

You can run the application in development mode:

```
./bin/setup && rails s
```

## Areas of Interest

This is a standard Rails API-only application, but there are some aspects worth
calling out:

- `config/initializers/auth.rb` -- ENV vars for setting credentials for the
  authenticated portions of the API. We support both HTTP Basic and token-based
  authentication.

- `config/initialiers/cors.rb` -- Configures `'localhost:3000`'` as an allowed
  CORS host. This allows you to make requests directly from the Swagger UI when
  using a tool like the [OpenAPI (Swagger) Editor][vscode-openapi] VSCode
  plugin.

- `config/application.rb` -- Configures the [committee][] middleware to validate
  both incoming and outgoing requests.

- `test/integration/posts_test.rb` -- Integration tests that demonstrate how
  the API responds.

[generated-spec]: ../spec/openapi/openapi.yaml
[committee]: https://github.com/interagent/committee
[spec-readme]: ../spec/README.md
[vscode-openapi]: https://marketplace.visualstudio.com/items?itemName=42Crunch.vscode-openapi
