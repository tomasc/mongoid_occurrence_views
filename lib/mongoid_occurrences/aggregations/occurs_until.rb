require 'mongoid_occurrences/aggregations/aggregation'

module MongoidOccurrences
  module Aggregations
    class OccursUntil < Aggregation
      def initialize(base_criteria, date_time, options = {})
        @base_criteria = base_criteria
        @date_time = date_time
        @options = options
      end

      private

      def criteria
        base_criteria.occurs_until(date_time)
      end

      def pipeline
        [
          { '$addFields' => { '_daily_occurrences' => '$daily_occurrences' } },
          { '$unwind' => { 'path' => '$_daily_occurrences' } },
          { '$addFields' => { '_dtstart' => '$_daily_occurrences.ds', '_dtend' => '$_daily_occurrences.de' } },
          { '$project' => { '_daily_occurrences' => 0 } },
          { '$match' => Queries::OccursUntil.criteria(base_criteria, date_time, dtend_field: '_dtend').selector },
          { '$sort' => { sort_key => { asc: 1, desc: -1 }[sort_order] } }
        ]
      end

      attr_reader :date_time, :options
    end
  end
end
