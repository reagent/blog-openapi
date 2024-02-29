# Generated TypeScript Blog API Client

This is a generated client application (using [`swagger-typescript-api`][sta])
for interacting with the API server and conforms to the same API specification
published in the [global specification][].

## Installation

Install dependencies with Yarn:

```
yarn
```

## Usage

Ensure that the [server][] is running and use the CLI to interact with the
service. To see a list of subcommands available:

```
yarn cli --help
```

The most useful starting point is the `post` subcommand. Make sure you're using
the correct credentials (see the [auth config][]) and create a new post:

```
yarn cli post --username admin --password password
```

```
┌  Create a New Post
│
◇  Title
│  New Post Title
│
◇  Body
│  New Post Body
Created post ID #1
✨  Done in 8.21s.
```

Since it's not published, you can't see it when you list posts:

```
yarn cli list
```

```
0 post(s) found

✨  Done in 0.95s.
```

You can see them if you are auth'd:

```
yarn cli list -u admin -p password
1 post(s) found

 * New Post Title (null)

✨  Done in 0.66s.
```

And you can publish:

```
yarn cli publish -u admin -p password
```

```
┌  Select post to publish
│
◆  Post
│  ● New Post Title
│  ○ Other Unpublished Post
└
```

Published posts will appear when not authenticated:

```
yarn cli list
```

```
1 post(s) found

 * New Post Title (2024-02-29T18:22:55.218Z)

✨  Done in 0.68s.
```

## Updating the Client

The server will pick up on changes to the [global specification][], but the
client code will not. Once the spec has been updated, regenerate the client:

```
yarn client:generate
```

You can then use the generate methods to interact with the API.

[sta]: https://github.com/acacode/swagger-typescript-api
[server]: ../server/README.md
[global specification]: ../spec/openapi/openapi.yaml
[auth config]: ../server/.env
