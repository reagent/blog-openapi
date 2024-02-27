import "@typespec/http";
import "@typespec/rest";
import "@typespec/openapi";
import "@typespec/openapi3";

using TypeSpec.Http;
using TypeSpec.OpenAPI;

scalar ID extends int32;

@error
model Error {
  message: string;
}

alias HTTPSuccessStatusCode = 200 | 201;
alias HTTPErrorStatusCode = 400 | 401 | 404 | 422;
alias HTTPStatusCode = HTTPSuccessStatusCode | HTTPErrorStatusCode;

model ErrorResponse<S extends HTTPErrorStatusCode> {
  @statusCode _: S;
  @body body: Error;
}

model NotFound is ErrorResponse<404>;
model Unauthorized is ErrorResponse<401>;
model BadRequest is ErrorResponse<400>;
model UnprocessableEntity is ErrorResponse<422>;

model SuccessResponse<S extends HTTPSuccessStatusCode, T> {
  @statusCode _: S;
  @body body: T;
}

model OK<T> is SuccessResponse<200, T>;
model Created<T> is SuccessResponse<201, T>;

model Post {
  id: ID;
  title: string;
  body: string;
  published_at: utcDateTime | null;
}

model PostCreate {
  title: string;
  body: string;
}

model PostUpdate {
  title?: string;
  body?: string;
}

model Posts {
  total: int32;
  posts: Array<Post>;
}

@service({
  title: "Blog API",
  version: "2024-02-22",
})
@info({
  contact: {
    email: "user@host.example",
  },
})
@server("http://localhost:3000", "Localhost")
@doc("API service to manage blog posts")
@useAuth(BasicAuth | BearerAuth)
namespace BlogService {
  @route("posts")
  @tag("post")
  namespace PostEndpoints {
    @get
    @route("{id}")
    @operationId("post-fetch")
    @doc("Fetch a single post")
    op fetch(@path id: ID): OK<Post> | NotFound;

    @get
    @operationId("post-list")
    @doc("List all posts available")
    op list(): OK<Posts> | Unauthorized;

    @post
    @operationId("post-create")
    @doc("Create a new post")
    op create(post: PostCreate):
      | Created<Post>
      | Unauthorized
      | BadRequest
      | UnprocessableEntity;

    @patch
    @route("{id}")
    @operationId("post-update")
    @doc("Update existing post")
    op update(@path id: ID, post: PostUpdate):
      | OK<Post>
      | NotFound
      | Unauthorized
      | BadRequest
      | UnprocessableEntity;

    @delete
    @route("{id}")
    @operationId("post-destroy")
    @doc("Destroy existing post")
    op destroy(@path id: ID): OK<Post> | NotFound | Unauthorized;

    @patch
    @route("{id}/publish")
    @operationId("post-publish")
    @doc("Set publish date of post to now")
    op publish(@path id: ID): OK<Post> | NotFound | Unauthorized;

    @patch
    @route("{id}/unpublish")
    @operationId("post-unpublish")
    @doc("Unset publish date of post")
    op unpublish(@path id: ID): OK<Post> | NotFound | Unauthorized;
  }
}
