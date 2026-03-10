class ContactQuery
  attr_reader :relation, :params

  def initialize(relation = Contact.all, params = {})
    @relation = relation
    @params = params
  end

  def resolve
    scope = relation
    scope = apply_search(scope)
    scope = apply_filter(scope)
    apply_sort(scope)
  end

  private

  def apply_search(scope)
    return scope if params[:query].blank?

    # Ecco il tuo fantastico FTS in azione!
    scope.search_text(params[:query])
  end

  def apply_filter(scope)
    case params[:filter]
    when "person"  then scope.person
    when "company" then scope.company
    else scope
    end
  end

  def apply_sort(scope)
    # Se la ricerca FTS è attiva, l'ordinamento per "rank"
    # di FtsSearchable prenderà il sopravvento, altrimenti usiamo il default.
    return scope if params[:query].present?

    # Ordinamento di default
    scope.order(last_name: :asc, first_name: :asc, company_name: :asc)
  end
end
