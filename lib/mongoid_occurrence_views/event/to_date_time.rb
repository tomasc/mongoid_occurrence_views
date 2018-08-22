module MongoidOccurrenceViews
  module Event
    class ToDateTime < Query
      def initialize(klass, date_time)
        @klass = klass
        @date_time = date_time
      end

      private

      attr_reader :date_time

      def criteria
        _date_time = date_time.beginning_of_day if date_time.instance_of?(Date)
        _date_time = date_time.utc
        base_class_criteria.gte(dtstart_field => _date_time)
      end
    end
  end
end
