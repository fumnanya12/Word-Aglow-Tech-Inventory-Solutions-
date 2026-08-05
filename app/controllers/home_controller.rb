class HomeController < ApplicationController
  def index
      @categories = Category.order(:name)
       @products = Product.includes(:category).limit(12).page(params[:page]).per(12)
       @cart = current_cart
  end
end
