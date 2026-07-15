ActiveAdmin.register Page do

  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
  permit_params :title, :slug, :content, :published
  #
  # or
  #
  # permit_params do
  #   permitted = [:title, :slug, :content, :published]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  # end
  index do
    selectable_column
    id_column
    column :title
    column :slug
    column :content
    column :published
    actions
  end

  filter :title
  filter :published
  filter :created_at
  filter :updated_at

  form do |f|
    f.inputs do
      f.input :title
      f.input :slug
      f.input :content
      f.input :published
    end
    f.actions
  end
end
