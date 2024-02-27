require 'test_helper'

class PostsTest < ActionDispatch::IntegrationTest
  class PostsIndexTest < PostsTest
    test 'GET :index returns no posts' do
      get '/posts'

      assert_response :ok
      assert_equal({ 'total' => 0, 'posts' => [] }, response.parsed_body)
    end

    test 'GET :index returns only published posts' do
      published_at = 1.day.ago

      published = create(:post, title: 'Title', body: 'Body', published_at:)
      _draft = create(:post, :draft)

      get '/posts'

      assert_response :ok
      assert_equal(
        {
          'total' => 1,
          'posts' => [
            {
              'id' => published.id,
              'title' => 'Title',
              'body' => 'Body',
              'published_at' => published_at.iso8601(3)
            }
          ]
        }, response.parsed_body
      )
    end

    test 'GET :index with invalid `Authorization` header responds with 401' do
      published = create(:post, :published)
      draft = create(:post, :draft)

      get '/posts', headers: { 'Authorization': 'o mg' }

      assert_response 401
      assert_equal({ 'message' => 'You are not authorized to perform this action' }, response.parsed_body)
    end

    test 'GET :index as authenticated user returns all posts' do
      with_basic_authentication do |username, password|
        published = create(:post, :published)
        draft = create(:post, :draft)

        authenticated_get '/posts', basic: { username:, password: }

        assert_response :ok
        total, posts = response.parsed_body.values_at('total', 'posts')

        assert_equal(2, total)
        assert_equal([published.id, draft.id], posts.pluck('id'))
      end
    end
  end

  class PostsShowTest < PostsTest
    test 'GET :show responds with 400 when the post ID is of an invalid type' do
      get '/posts/adsf'

      assert_response 400
      assert_equal(
        {
          'message' => '#/components/schemas/ID expected integer, but received String: "adsf"'
        }, response.parsed_body
      )
    end

    test 'GET :show responds with 404 when the post does not exist' do
      get '/posts/1'

      assert_response 404
      assert_equal({ 'message' => "Couldn't find Post with 'id'=1" }, response.parsed_body)
    end

    test 'GET :show responds with 404 when the post is not published' do
      draft = create(:post, :draft)
      get "/posts/#{draft.id}"

      assert_response 404
      assert_equal({ 'message' => "Couldn't find Post with 'id'=#{draft.id}" }, response.parsed_body)
    end

    test 'GET :show returns the published post' do
      published_at = 1.day.ago
      published = create(:post, title: 'Title', body: 'Body', published_at:)

      get "/posts/#{published.id}"

      assert_response 200
      assert_equal(
        {
          'id' => published.id,
          'title' => 'Title',
          'body' => 'Body',
          'published_at' => published_at.iso8601(3)
        }, response.parsed_body
      )
    end

    test 'GET :show as authenticated user returns draft post' do
      with_basic_authentication do |username, password|
        published_at = 1.day.from_now
        draft = create(:post, title: 'Title', body: 'Body', published_at:)

        authenticated_get "/posts/#{draft.id}", basic: { username:, password: }

        assert_response 200

        assert_equal(
          {
            'id' => draft.id,
            'title' => 'Title',
            'body' => 'Body',
            'published_at' => published_at.iso8601(3)
          }, response.parsed_body
        )
      end
    end
  end

  class PostsCreateTest < PostsTest
    test 'POST :create with invalid body responds with 400' do
      post '/posts', { post: {} }

      assert_response 400

      assert_equal(
        { 'message' => '#/components/schemas/PostCreate missing required parameters: title, body' },
        response.parsed_body
      )
    end

    test 'POST :create without authentication responds with 401' do
      post '/posts', { post: { title: 'Title', body: 'Body' } }

      assert_response 401
      assert_equal({ 'message' => 'You are not authorized to perform this action' }, response.parsed_body)
    end

    test 'POST :create responds with 201 and persists the post' do
      with_basic_authentication do |username, password|
        authenticated_post('/posts', { post: { title: 'Title', body: 'Body' } }, basic: { username:, password: })

        assert_equal(1, Post.count)

        post = Post.first

        assert_equal('Title', post.title)
        assert_equal('Body', post.body)

        assert_response 201

        assert_equal(
          {
            'id' => post.id,
            'title' => 'Title',
            'body' => 'Body',
            'published_at' => nil
          }, response.parsed_body
        )
      end
    end

    test 'POST :create responds with 201 and persists the post when authenticating with Bearer token' do
      with_bearer_authentication do |token|
        authenticated_post('/posts', { post: { title: 'Title', body: 'Body' } }, bearer: token)

        assert_equal(1, Post.count)

        post = Post.first

        assert_equal('Title', post.title)
        assert_equal('Body', post.body)

        assert_response 201

        assert_equal(
          {
            'id' => post.id,
            'title' => 'Title',
            'body' => 'Body',
            'published_at' => nil
          }, response.parsed_body
        )
      end
    end

    test 'POST :create responds with 422 when attempting to create with invalid data' do
      with_basic_authentication do |username, password|
        authenticated_post('/posts', { post: { title: '', body: 'Body' } }, basic: { username:, password: })

        assert_response 422
        assert_equal({ 'message' => "Validation failed: Title can't be blank" }, response.parsed_body)

        assert_equal(0, Post.count)
      end
    end
  end

  class PostsUpdateTest < PostsTest
    test 'PATCH :update responds with 401 when no credentials provided' do
      post = create(:post)
      patch "/posts/#{post.id}", {}

      assert_response 401
      assert_equal(
        { 'message' => 'You are not authorized to perform this action' },
        response.parsed_body
      )
    end

    test 'PATCH :update responds with 404 when authenticated but the post does not exist' do
      with_basic_authentication do |username, password|
        authenticated_patch '/posts/1', { post: { title: 'New Title' } }, basic: { username:, password: }

        assert_response 404

        assert_equal(
          { 'message' => "Couldn't find Post with 'id'=1" },
          response.parsed_body
        )
      end
    end

    test 'PATCH :update responds with 400 when sending unknown properties' do
      skip('Need solution for `additionalProperties: false` on request bodies')
      with_basic_authentication do |username, password|
        post = create(:post)
        authenticated_patch "/posts/#{post.id}", { post: { bogus: 'value' } }, basic: { username:, password: }

        assert_response 400
      end
    end

    test 'PATCH :update responds with 422 when the update fails' do
      with_basic_authentication do |username, password|
        post = create(:post)
        authenticated_patch("/posts/#{post.id}", { post: { title: '' } }, basic: { username:, password: })

        assert_response 422

        assert_equal(
          { 'message' => "Validation failed: Title can't be blank" },
          response.parsed_body
        )
      end
    end

    test 'PATCH :update responds with 200 and modifies the post' do
      with_basic_authentication do |username, password|
        post = create(:post, title: 'Old', body: 'Old Body')

        authenticated_patch(
          "/posts/#{post.id}",
          { post: { title: 'New', body: 'New Body' } },
          basic: { username:, password: }
        )

        assert_response 200

        assert_equal(
          {
            'id' => post.id,
            'title' => 'New',
            'body' => 'New Body',
            'published_at' => nil
          }, response.parsed_body
        )

        post.reload

        assert_equal('New', post.title)
        assert_equal('New Body', post.body)
      end
    end
  end

  class PostsDestroyTest < PostsTest
    test 'DELETE :destroy responds with 401 when no credentials provided' do
      post = create(:post)
      delete "/posts/#{post.id}"

      assert_response 401
      assert_equal(
        { 'message' => 'You are not authorized to perform this action' },
        response.parsed_body
      )
    end

    test 'DELETE :destroy responds with 404 when authenticated but the post does not exist' do
      with_basic_authentication do |username, password|
        authenticated_delete '/posts/1', basic: { username:, password: }

        assert_response 404

        assert_equal(
          { 'message' => "Couldn't find Post with 'id'=1" },
          response.parsed_body
        )
      end
    end

    test 'DELETE :destroy responds with 200 and removes the post' do
      with_basic_authentication do |username, password|
        post = create(:post, title: 'Old', body: 'Old Body')

        authenticated_delete("/posts/#{post.id}", basic: { username:, password: })

        assert_response 200

        assert_equal(
          {
            'id' => post.id,
            'title' => 'Old',
            'body' => 'Old Body',
            'published_at' => nil
          }, response.parsed_body
        )

        assert_nil Post.find_by(id: post.id)
      end
    end
  end

  class PostsPublishTest < PostsTest
    include ActiveSupport::Testing::TimeHelpers

    test 'PATCH :publish responds with 401 when unauthorized' do
      patch '/posts/1/publish'

      assert_response 401
      assert_equal({ 'message' => 'You are not authorized to perform this action' }, response.parsed_body)
    end

    test 'PATCH :publish responds with 404 when the post cannot be found' do
      with_basic_authentication do |username, password|
        authenticated_patch('/posts/1/publish', basic: { username:, password: })

        assert_response 404
        assert_equal({ 'message' => "Couldn't find Post with 'id'=1" }, response.parsed_body)
      end
    end

    test 'PATCH :publish responds with 200 and sets the publish date of a post that is not yet published' do
      now = Time.zone.parse('2024-08-01T00:00:00Z')

      travel_to now

      with_basic_authentication do |username, password|
        post = create(:post, published_at: nil)
        authenticated_patch("/posts/#{post.id}/publish", basic: { username:, password: })

        assert_response 200

        assert_equal(
          {
            'id' => post.id,
            'title' => 'title',
            'body' => 'body',
            'published_at' => '2024-08-01T00:00:00.000Z'
          }, response.parsed_body
        )

        assert_equal(now, post.reload.published_at)
      end
    end

    test 'PATCH :publish does not change the date of a post published in the past' do
      with_basic_authentication do |username, password|
        published_at = '2020-01-01T00:00:00.000Z'
        post = create(:post, published_at:)

        authenticated_patch("/posts/#{post.id}/publish", basic: { username:, password: })

        assert_response 200
        assert_equal(published_at, response.parsed_body['published_at'])
        assert_equal(Time.zone.parse(published_at), post.reload.published_at)
      end
    end

    test 'PATCH :publish changes the date of a post published in the future' do
      now = '2024-08-01T00:00:00.000Z'

      travel_to now

      with_basic_authentication do |username, password|
        post = create(:post, published_at: 1.year.from_now)

        authenticated_patch("/posts/#{post.id}/publish", basic: { username:, password: })

        assert_response 200
        assert_equal(now, response.parsed_body['published_at'])
        assert_equal(Time.zone.parse(now), post.reload.published_at)
      end
    end
  end

  class PostsUnpublishTest < PostsTest
    test 'PATCH :unpublish responds with 400 when the post ID is an invalid type' do
      patch '/posts/asdf/unpublish'

      assert_response 400
      assert_equal(
        { 'message' => '#/components/schemas/ID expected integer, but received String: "asdf"' },
        response.parsed_body
      )
    end

    test 'PATCH :unpublish responds with 401 when unauthorized' do
      patch '/posts/1/unpublish'

      assert_response 401
      assert_equal({ 'message' => 'You are not authorized to perform this action' }, response.parsed_body)
    end

    test 'PATCH :unpublish responds with 404 when the post cannot be found' do
      with_basic_authentication do |username, password|
        authenticated_patch('/posts/1/unpublish', basic: { username:, password: })

        assert_response 404
        assert_equal({ 'message' => "Couldn't find Post with 'id'=1" }, response.parsed_body)
      end
    end

    test 'PATCH :unpublish responds with 200 and unsets the publish date of a post that is published' do
      with_basic_authentication do |username, password|
        post = create(:post, published_at: 1.day.ago)
        authenticated_patch("/posts/#{post.id}/unpublish", basic: { username:, password: })

        assert_response 200

        assert_equal(
          {
            'id' => post.id,
            'title' => 'title',
            'body' => 'body',
            'published_at' => nil
          }, response.parsed_body
        )

        assert_nil post.reload.published_at
      end
    end
  end

  protected

  def post(path, body = {}, headers: {})
    super(path, params: body.to_json, headers: { 'Content-Type': 'application/json' }.merge(headers))
  end

  def patch(path, body = {}, headers: {})
    super(path, params: body.to_json, headers: { 'Content-Type': 'application/json' }.merge(headers))
  end

  def delete(path, headers: {})
    super(path, headers: { 'Content-Type': 'application/json' }.merge(headers))
  end

  def authenticated_get(path, basic: nil, bearer: nil)
    get(path, headers: auth_header_for(basic:, bearer:))
  end

  def authenticated_post(path, body = {}, basic: nil, bearer: nil)
    post(path, body, headers: auth_header_for(basic:, bearer:))
  end

  def authenticated_patch(path, body = {}, basic: nil, bearer: nil)
    patch(path, body, headers: auth_header_for(basic:, bearer:))
  end

  def authenticated_delete(path, basic: nil, bearer: nil)
    delete(path, headers: auth_header_for(basic:, bearer:))
  end

  def with_basic_authentication(&)
    credentials = {
      username: Rails.configuration.x.auth.basic.username,
      password: Rails.configuration.x.auth.basic.password
    }

    username = SecureRandom.uuid
    password = SecureRandom.uuid

    Rails.configuration.x.auth.basic.username = username
    Rails.configuration.x.auth.basic.password = password

    yield username, password

    Rails.configuration.x.auth.basic.username = credentials[:username]
    Rails.configuration.x.auth.basic.password = credentials[:password]
  end

  def with_bearer_authentication(&)
    existing_token = Rails.configuration.x.auth.bearer.token

    token = SecureRandom.uuid

    Rails.configuration.x.auth.bearer.token = token

    yield token

    Rails.configuration.x.auth.bearer.token = existing_token
  end

  def auth_header_for(basic: nil, bearer: nil)
    raise 'Provide credentials for basic or bearer auth' unless basic || bearer

    value = if basic.present?
              username, password = basic.values_at(:username, :password)
              basic_auth_header_value_for(username, password)
            else
              "Bearer #{bearer}"
            end

    { 'Authorization': value }
  end

  def basic_auth_header_value_for(username, password)
    encoded = Base64.strict_encode64([username, password].join(':'))
    "Basic #{encoded}"
  end
end
