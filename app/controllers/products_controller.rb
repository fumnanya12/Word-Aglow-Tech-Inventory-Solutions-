class ProductsController < ApplicationController
  def index
    @categories = Category.order(:name)
    @products = Product.includes(:category)

    if params[:search].present?
      keyword = "%#{ActiveRecord::Base.sanitize_sql_like(params[:search])}%"

      @products = @products.where(
        "products.name LIKE :keyword OR products.description LIKE :keyword",
        keyword: keyword
      )
      @products_search=@products.where(
        "products.name LIKE :keyword OR products.description LIKE :keyword",
        keyword: keyword
      ).page(params[:page]).per(20)
    end

    if params[:category_id].present?
      @selected_category = Category.find(params[:category_id])
      @products = @products.where(category_id: params[:category_id])
      @products_search= @products.where(category_id: params[:category_id]).page(params[:page]).per(20)
    end
  case params[:filter]
  when "available"
    @products = @products.where(avaliable: true)
    @products_search=@products
  when "new"
    @products = @products.where(created_at: 3.days.ago..Time.current)
    @products_search=@products
  when "recently_updated"
    @products = @products
      .where(updated_at: 3.days.ago..Time.current)
      .where("created_at < ?", 3.days.ago)
    @products_search=@products
  end


    @products = @products.page(params[:page]).per(12)
    @products_search=@products
  end

  def show
    @categories = Category.order(:name)

    @product = Product.find(params[:id])
  end
end
#   def index
#     @products_search=[]
#     @products=[]
#     if params[:query].present?
#       search = "%#{params[:query]}%"
#       @products_search=Product.where(
#         "name LIKE :search",
#         search: search
#       ).page(params[:page])
#       .per(30)
#     else
#       @products=Product.all
#      .page(params[:page])
#       .per(30)
#     end
#   end

#   def show
#     @products=Product.find(params[:id])
#   end
