require 'mongoid_occurrence_views/aggregations/aggregation'

module MongoidOccurrenceViews
  module Aggregations
    class OccursBetween < Aggregation
      def initialize(base_criteria, dtstart, dtend, options = {})
        @base_criteria = base_criteria

        @dtstart = dtstart
        @dtend = dtend

        @allow_disk_use = options.fetch(:allow_disk_use, true)

        @sort_key = options.fetch(:sort_key, :_dtstart)
        @sort_order = options.fetch(:sort_order, :asc)

        @aggregation = base_criteria.klass
                                    .collection
                                    .aggregate(
                                      (selectors + pipeline),
                                      allow_disk_use: allow_disk_use
                                    )
      end

      def instantiate
        aggregation.map do |doc|
          base_criteria.klass.instantiate(doc)
        end
      end

      private

      def criteria
        base_criteria.occurs_between(dtstart, dtend)
      end

      def pipeline
        [
          { '$addFields' => { '_daily_occurrences' => '$daily_occurrences' } },
          { '$unwind' => { 'path' => '$_daily_occurrences' } },
          { '$addFields' => { '_dtstart' => '$_daily_occurrences.ds', '_dtend' => '$_daily_occurrences.de' } },
          { '$match' => Queries::OccursBetween.criteria(base_criteria, dtstart, dtend, dtstart_field: '_dtstart', dtend_field: '_dtend').selector },
          { '$sort' => { sort_key => { asc: 1, desc: -1 }[sort_order] } }
        ]
      end

      attr_reader :aggregation, :allow_disk_use, :dtstart, :dtend, :sort_key, :sort_order
    end
  end
end
