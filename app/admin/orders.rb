ActiveAdmin.register Order do
   # See permitted parameters documentation:
   # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
   #
   # Uncomment all parameters which should be permitted for assignment
   #
   permit_params :customer_id, :status, :subtotal, :tax, :total, :shipping_address, :placed_at
   #
   # or
   #
   # permit_params do
   #   permitted = [:customer_id, :status, :subtotal, :tax, :total, :shipping_address, :placed_at]
   #   permitted << :other if params[:action] == 'create' && current_user.admin?
   #   permitted
   # end
   includes :customer, order_items: :product

  filter :id
  filter :customer
  filter :status, as: :select
  filter :placed_at
  filter :created_at


  index do
    selectable_column
    id_column

    column :customer do |order|
      "#{order.customer.first_name} #{order.customer.last_name}"
    end

    column "Products" do |order|
      ul do
        order.order_items.each do |order_item|
          li "#{order_item.product.name} × #{order_item.quantity}"
        end
      end
    end

    column :subtotal
    column :tax
    column :total
    column :status
    column :placed_at
    column :created_at

    actions
  end
end
