class WinesController < ApplicationController
  before_action :set_wine, only: [:show, :edit, :update, :destroy]
  before_action :authorize_wine!, only: [:edit, :update, :destroy]

  def index
    @wines = Wine.all.order(:name)
  end

  def show
    @posts = @wine.posts.order(created_at: 'DESC')
  end

  def new
    @wine = Wine.new
  end

  def create
    @wine = Wine.new(wine_params)
    @wine.user = current_user

    if @wine.save
      redirect_to @wine, notice: "Wine was successfully added."
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @wine.update(wine_params)
      redirect_to @wine, notice: "Wine was successfully updated."
    else
      render :edit
    end
  end

  def destroy
    @wine.destroy
    redirect_to wines_path, notice: "Wine was removed."
  end

  private

  def set_wine
    @wine = Wine.find(params[:id])
  end

  def authorize_wine!
    unless @wine.user_id == current_user.id
      flash[:alert] = "You are not authorized to do that."
      redirect_to wines_path
    end
  end

  def wine_params
    params.require(:wine).permit(:name, :varietal, :vintage, :origin, :description)
  end
end
