ActiveAdmin.register Customer do
  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
  # permit_params :email, :encrypted_password, :reset_password_token, :reset_password_sent_at, :remember_created_at, :sign_in_count, :current_sign_in_at, :last_sign_in_at, :current_sign_in_ip, :last_sign_in_ip, :username, :first_name, :last_name, :address_line_one, :address_line_two, :city, :province, :postal_code, :country
  #
  # or
  #
  # permit_params do
  #   permitted = [:email, :encrypted_password, :reset_password_token, :reset_password_sent_at, :remember_created_at, :sign_in_count, :current_sign_in_at, :last_sign_in_at, :current_sign_in_ip, :last_sign_in_ip, :username, :first_name, :last_name, :address_line_one, :address_line_two, :city, :province, :postal_code, :country]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  # end
   config.batch_actions = false

  permit_params :username,
              :email,
              :password,
              :password_confirmation,
              :first_name,
              :last_name,
              :address_line_one,
              :address_line_two,
              :city,
              :province_id,
              :postal_code

  index do
    selectable_column
    id_column

    column :username
    column :email
    column :first_name
    column :last_name
    column :city
    column "Province" do |customer|
        "#{customer.province&.name} (#{customer.province&.abbreviation})"
      end
    column :created_at

    actions defaults: false do |customer|
      item "View", admin_customer_path(customer)
      item "Edit", edit_admin_customer_path(customer)

      span do
        button_to "Delete",
                  admin_customer_path(customer),
                  method: :delete,
                  form: {
                    data: {
                      turbo: false
                    },
                    onsubmit: "return confirm('Are you sure you want to delete this customer?');"

                  }
      end
    end
  end

  filter :username
  filter :email
  filter :first_name
  filter :last_name
  filter :city
  filter :province_id
  filter :created_at

  show do
    attributes_table do
      row :id
      row :username
      row :email
      row :first_name
      row :last_name
      row :address_line_one
      row :address_line_two
      row :city
      row "Province" do |customer|
            "#{customer.province&.name} (#{customer.province&.abbreviation})"
      end
      row :postal_code
      row :created_at
      row :updated_at
    end
  end

form do |f|
  f.inputs "Customer Details" do
    f.input :username
    f.input :email

    if f.object.new_record?
      f.input :password
      f.input :password_confirmation
    end

    f.input :first_name
    f.input :last_name
    f.input :address_line_one
    f.input :address_line_two
    f.input :city
    f.input :province
    f.input :postal_code
  end

  f.actions
end

end
