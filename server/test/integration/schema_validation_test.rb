require 'test_helper'

class SchemaValidationTest < ActionDispatch::IntegrationTest
  test 'response that does not match the spec raises Committee::InvalidResponse' do
    post = create(:post, :published)

    with_post_partial('json.extract! post, :id, :title, :published_at') do
      error = assert_raises(Committee::InvalidResponse) { get "/posts/#{post.id}" }
      assert_match(/missing required parameters: body/, error.message)
    end
  end

  test 'route that is not in the spec responds with 404' do
    get '/not-in-spec'

    assert_response :not_found
    assert_equal(
      { 'message' => "That request method and path combination isn't defined." },
      response.parsed_body
    )
  end

  private

  def with_post_partial(source)
    original_view_paths = PostsController.view_paths

    Dir.mktmpdir do |dir|
      FileUtils.mkdir_p(File.join(dir, 'posts'))
      File.write(File.join(dir, 'posts', '_post.json.jbuilder'), source)

      PostsController.prepend_view_path(dir)
      yield
    ensure
      PostsController.view_paths = original_view_paths
    end
  end
end
