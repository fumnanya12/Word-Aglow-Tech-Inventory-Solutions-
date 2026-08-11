ActiveAdmin.register_page "Customer Order Report" do
  menu label: "Customer Order Report", priority: 5

  content title: "Customer Order Report" do
    customers = Customer
      .joins(:orders)
      .includes(:province, orders: { order_items: :product })
      .distinct
      .order(:last_name, :first_name)

    customers.each do |customer|
      panel "#{customer.first_name} #{customer.last_name}" do
        attributes_table_for customer do
          row :id
          row :username
          row :email

          row "Province" do
            customer.province&.name || "Not provided"
          end
        end

        customer.orders.each do |order|
          panel "Order ##{order.id}" do
            attributes_table_for order do
              row :status

              row "Order Date" do
                order.created_at.strftime("%B %d, %Y")
              end

              row "Products Ordered" do
                ul do
                  order.order_items.each do |order_item|
                    li do
                      "#{order_item.product.name} × #{order_item.quantity}"
                    end
                  end
                end
              end

              row "Subtotal" do
                number_to_currency(order.subtotal)
              end

              row "Tax" do
                number_to_currency(order.tax)
              end

              row "Grand Total" do
                number_to_currency(order.total)
              end
            end
          end
        end
      end
    end
  end
end
