# frozen_string_literal: true

class SearchTerm < ApplicationRecord
  validates :search_term, presence: true

  after_save :consolidate_partial_search_terms

  def consolidate_partial_search_terms
    latest_search_term = SearchTerm.order(created_at: :desc).first
    return unless latest_search_term&.search_term.present?

    latest_words = latest_search_term.search_term.split(/\s+/).reject(&:blank?)
    older_search_terms = SearchTerm.where.not(id: latest_search_term.id)

    older_search_terms.each do |older_search_term|
      next unless older_search_term.search_term.present?

      older_words = older_search_term.search_term.split(/\s+/).reject(&:blank?)

      next if older_words.empty?

      if older_words.all? { |older_word| latest_words.any? { |latest_word| latest_word.start_with?(older_word) } }
        older_search_term.destroy
      end
    end
  end

  def self.search_term_suggestions(search_term)
    search_term.downcase!
    return if search_term.blank?

    where('LOWER(search_term) LIKE ?', "%#{search_term}%")
  end

  def self.your_most_recent_search_terms(user_ip)
    where(user_ip: user_ip).order(created_at: :desc).limit(5)
  end

  def self.your_most_frequent_search_terms(user_ip)
    where(user_ip: user_ip).order(count: :desc).limit(5)
  end

  def self.most_frequent_search_terms
    Rails.cache.fetch('most_frequent_search_terms', expires_in: 15.seconds) do
      order(count: :desc).limit(5)
    end
  end

  def self.search_term_similarity(search_term1, search_term2)
    puts "The value of DamerauLevenshtein is #{DamerauLevenshtein.distance(search_term1, search_term2)}"
    DamerauLevenshtein.distance(search_term1, search_term2)
  end

  def self.log_search(search_term, user_ip)
    recent_search = where(user_ip: user_ip).order(created_at: :desc).first
    if recent_search && (Time.current - recent_search.created_at) <= 1.minute &&
       search_term_similarity(recent_search.search_term, search_term) <= 5
      recent_search.update(search_term: search_term, count: recent_search.count + 1)
    else
      term_to_log = where(search_term: search_term, user_ip: user_ip).first_or_initialize

      if term_to_log.new_record?
        existing_term = SearchTerm.where('search_term LIKE ? AND user_ip = ?', "#{search_term}%", user_ip).first
        term_to_log.destroy if existing_term
      else
        term_to_log.increment!(:count)
      end

      term_to_log.save
    end
  end
end
