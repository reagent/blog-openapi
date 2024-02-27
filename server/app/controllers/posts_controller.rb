class PostsController < ApplicationController
  before_action :authorize, only: %i[create update destroy publish unpublish]
  before_action :assign_post, only: %i[update destroy publish unpublish]

  def index
    @posts = authenticated? ? Post.all : Post.published
  end

  def show
    scope = authenticated? ? Post : Post.published
    @post = scope.find(params[:id])
  end

  def create
    @post = Post.new(post_params)
    @post.save!

    render :create, status: :created
  end

  def update
    @post.update!(post_params)
  end

  def destroy
    @post.destroy!
  end

  def publish
    @post.publish!
  end

  def unpublish
    @post.unpublish!
  end

  private

  def post_params
    params.require(:post).permit(:title, :body)
  end

  def assign_post
    @post = Post.find(params[:id])
  end

  def authorize
    return if authenticated?

    render(
      json: { message: 'You are not authorized to perform this action' },
      status: :unauthorized
    )
  end
end
