class SearchesController < ApplicationController
  def index
    user_ip = request.ip
    @most_frequent_search_terms = SearchTerm.most_frequent_search_terms
    @your_most_frequent_search_terms = SearchTerm.your_most_frequent_search_terms(user_ip)
    @your_most_recent_search_terms = SearchTerm.your_most_recent_search_terms(user_ip)
  end

  def create
    search_term = params[:search_term].downcase.strip
    user_ip = request.ip
    SearchTerm.log_search(search_term, user_ip)
    render json: { status: 'success' }
  end

  def suggestions
    search_term = params[:search_term].downcase.strip
    similar_search_terms = SearchTerm.search_term_suggestions(search_term)
    render json: { suggestions: similar_search_terms }
  end
end