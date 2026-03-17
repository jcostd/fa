class Jobs::ContactsController < ApplicationController
  def new
    kind = params[:kind].presence || "person"
    @contact = Contact.new(kind: kind)

    if params[:name].present?
      if kind == "company"
        @contact.company_name = params[:name]
      else
        names = params[:name].split(" ", 2)
        @contact.first_name = names[0]
        @contact.last_name = names[1]
      end
    end

    submit_url = jobs_contacts_path(role: params[:role])
    render "contacts/new", layout: "modal", locals: { submit_url: submit_url }
  end

  def create
    @contact = Contact.new(contact_params)
    @role = params[:role]

    unless @contact.save
      submit_url = jobs_contacts_path(role: @role)
      render "contacts/new", layout: "modal", locals: { submit_url: submit_url }, status: :unprocessable_entity
    end
  end

  private
    def contact_params
      params.require(:contact).permit(
        :kind,
        :first_name, :last_name,
        :company_name,
        :phone, :email, :vat_number, :tax_id)
    end
end
