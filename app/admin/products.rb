ActiveAdmin.register Product do

  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
  permit_params :category_id, :name, :description, :rental_price, :product_price, :stock_quanity, :avaliable, :sku
  #
  # or
  #
  # permit_params do
  #   permitted = [:category_id, :name, :description, :rental_price, :product_price, :stock_quanity, :avaliable, :sku]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  # end
  
  filter :name
  filter :category
  filter :price
  filter :created_at
   form do |f|
    f.inputs "Product Details" do
      f.input :name
      f.input :description
      f.input :product_price
      f.input :rental_price
      f.input :stock_quanity
      f.input :category_id
      f.input :sku
      f.input :avaliable

    end

    f.actions
  end
end
