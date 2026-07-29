ActiveAdmin.register Province do
  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
  permit_params :name, :abbreviation, :pst_rate, :gst_rate, :hst_rate
  #
  # or
  #
  # permit_params do
  #   permitted = [:name, :abbreviation, :pst_rate, :gst_rate, :hst_rate]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  # end
  #
  #
  index do
    selectable_column
    id_column

    column :name
    column :abbreviation
    column :pst_rate
    column :gst_rate
    column :hst_rate
    column :created_at
    column :update_at

    actions
  end

  show do
    attributes_table do
      row :id
      row :name
      row :name
      row :pst_rate
      row :gst_rate
      row :hst_rate
      row :created_at
      row :updated_at
    end
  end

form do |f|
    f.inputs "Enter Province" do
      f.input :name
      f.input :abbreviation
      f.input :pst_rate
      f.input :gst_rate
      f.input :hst_rate
    end

    f.actions
  end
end
