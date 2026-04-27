class UsersController < ApplicationController
  skip_before_action :require_login, only: [:new, :create]

  def index
    @users = User.all
    @user = current_user
  end

  def welcome_user
    @user = current_user
  end

  def new_user_profile
    @user = current_user
    @posts = Post.all.order(created_at: 'DESC')
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(
      first_name: params[:first_name],
      last_name: params[:last_name],
      email: params[:email],
      password: params[:password],
      password_confirmation: params[:password_confirmation]
    )

    if @user.save
      session[:user_id] = @user.id
      redirect_to "/users/welcome_user", notice: "Welcome to WynTaste!"
    else
      flash.now[:alert] = @user.errors.full_messages.to_sentence
      render :new
    end
  end
end
