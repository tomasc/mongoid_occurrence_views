require 'mongoid_occurrence_views/daily_occurrence/has_scopes'

module MongoidOccurrenceViews
  class DailyOccurrence
    include Mongoid::Document
    include HasScopes

    attr_accessor :operator

    field :ds, as: :dtstart, type: DateTime
    field :de, as: :dtend, type: DateTime

    validates :dtstart, presence: true
    validates :dtend, presence: true

    def operator
      @operator ||= :append
    end

    def all_day
      dtstart.to_i == dtstart.beginning_of_day.to_i &&
        dtend.to_i == dtend.end_of_day.to_i
    end
    alias all_day? all_day
  end
end