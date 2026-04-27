class PostsController < ApplicationController

  def show
    @post = Post.find(params[:id])
    @user = current_user
  end

  def new
    @user = current_user
    @post = Post.new(user_id: current_user.id)
  end

  def new_user_profile
    @user = current_user
    @posts = Post.all.order(created_at: 'ASC')
  end

  def edit
    @post = Post.find(params[:id])
    authorize_owner!(@post)
  end

  def create
    @user = current_user
    @post = @user.posts.new(post_params)
    if @post.save
      redirect_to "/posts/#{@post.id}"
    else
      render :new
    end
  end

  def update
    @post = Post.find(params[:id])
    authorize_owner!(@post)
    return if performed?

    if @post.update(post_params)
      redirect_to @post
    else
      render :edit
    end
  end

  def destroy
    @post = Post.find(params[:id])
    authorize_owner!(@post)
    return if performed?

    @post.destroy
    redirect_to '/users'
  end

  private

  def post_params
    params.require(:post).permit(:title, :text, :image, :rating, :user_id, :wine_id)
  end
end
