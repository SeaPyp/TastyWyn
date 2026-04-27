class UsersController < ApplicationController
  skip_before_action :require_login, only: [:new, :create]
  before_action :set_user, only: [:show, :edit, :update]

  def index
    @users = User.all
    @user = current_user
  end

  def show
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
      redirect_to welcome_user_users_path, notice: "Welcome to WynTaste!"
    else
      flash.now[:alert] = @user.errors.full_messages.to_sentence
      render :new
    end
  end

  def edit
    authorize_self!(@user)
  end

  def update
    authorize_self!(@user)
    return if performed?

    if @user.update(user_params)
      redirect_to user_path(@user), notice: "Profile updated."
    else
      flash.now[:alert] = @user.errors.full_messages.to_sentence
      render :edit
    end
  end

  def welcome_user
    @user = current_user
  end

  def new_user_profile
    @user = current_user
    @posts = Post.all.order(created_at: 'DESC')
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def authorize_self!(user)
    unless user.id == current_user.id
      flash[:alert] = "You can only edit your own profile."
      redirect_to user_path(current_user)
    end
  end

  def user_params
    params.require(:user).permit(:first_name, :last_name, :email, :password, :password_confirmation)
  end
end
