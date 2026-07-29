class CustomerProfilesController < ApplicationController
  before_action :authenticate_customer!
  before_action :set_customer

  def show
    @categories = Category.order(:name)
  end

  def edit
    @categories = Category.order(:name)
  end

  def update
    if @customer.update(customer_params)
      redirect_to customer_profile_path,
                  notice: "Your account details were updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_customer
    @customer = current_customer
  end

  def customer_params
    params.require(:customer).permit(
      :username,
      :first_name,
      :last_name,
      :address_line_one,
      :address_line_two,
      :city,
      :province,
      :postal_code
    )
  end
end
