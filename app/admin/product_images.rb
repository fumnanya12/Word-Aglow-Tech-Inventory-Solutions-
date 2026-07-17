ActiveAdmin.register ProductImage do
  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
  # permit_params :product_id, :alt_text, :position
  #
  # or
  #
  # permit_params do
  #   permitted = [:product_id, :alt_text, :position]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  # end
  permit_params :product_id, :alt_text, :position, :image
  filter :product
  filter :alt_text
  filter :position
  filter :created_at
  form html: { multipart: true } do |f|
    f.inputs do
      f.input :product
      f.input :image, as: :file
      f.input :alt_text
      f.input :position
    end

    f.actions
  end
   show do
    attributes_table do
      row :product
      row :alt_text
      row :position

      row :image do |product_image|
        if product_image.image.attached?
          image_tag url_for(product_image.image), width: 300
        else
          "No image uploaded"
        end
      end
    end
  end
end
