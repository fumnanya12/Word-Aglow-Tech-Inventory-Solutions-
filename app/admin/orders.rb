ActiveAdmin.register Order do
   # See permitted parameters documentation:
   # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
   #
   # Uncomment all parameters which should be permitted for assignment
   #
   config.batch_actions = false

   permit_params :customer_id, :status, :subtotal,:gst_amount,:hst_amount,:pst_amount, :tax, :total, :shipping_address, :placed_at
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
    
    id_column

    column :customer do |order|
      "#{order.customer.first_name} #{order.customer.last_name}"
    end

    column "Products" do |order|
      ul do
        order.order_items.each do |order_item|
          li "#{order_item.product_name} × #{order_item.quantity}"
        end
      end
    end

    column :subtotal
    column :gst_amount
    column :hst_amount
    column :pst_amount
    column :tax
    column :total
    column :status
    column :placed_at
    column :created_at

    actions defaults: false do |order|
      item "View", admin_order_path(order)
      item "Edit", edit_admin_order_path(order)

      span do
        button_to "Delete",
                  admin_order_path(order),
                  method: :delete,
                  form: {
                    data: {
                      turbo: false
                    },
                    onsubmit: "return confirm('Are you sure you want to delete this order');"
                  }
      end
    end
   
  end


end
