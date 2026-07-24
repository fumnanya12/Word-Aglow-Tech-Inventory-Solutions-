class HomeController < ApplicationController
  def index
      @categories = Category.order(:name)
       @products = Product.includes(:category).limit(9).page(params[:page]).per(9)
  end
end
