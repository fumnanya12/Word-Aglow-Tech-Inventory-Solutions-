class PagesController < ApplicationController
  def about
    @page = Page.find_by!(slug: "about", published: true)
  end
  def contact
    @page = Page.find_by!(slug: "contact", published: true)
  end
  def show
    @page = Page.where(published: true).find_by!(slug: params[:slug])
  end
end
