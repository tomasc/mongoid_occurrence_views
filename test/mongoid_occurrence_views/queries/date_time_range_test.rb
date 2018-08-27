require 'test_helper'

describe MongoidOccurrenceViews::Queries::DateTimeRange do
  let(:today) { DateTime.now.beginning_of_day }
  let(:query) { subject.criteria(klass, query_dtstart, query_dtend) }
  let(:query_with_no_match) { subject.criteria(klass, query_dtstart - 1.year, query_dtend - 1.year) }

  describe 'Querying Events' do
    let(:klass) { Event }

    before { event.save! }

    describe 'spanning one day' do
      let(:event) { build(:event, :today) }
      let(:query_dtstart) { today }
      let(:query_dtend) { today.end_of_day }

      it { query.count.must_equal 1 }
      it { query_with_no_match.count.must_equal 0 }

      it { with_expanded_occurrences_view { query.count.must_equal 1 } }
      it { with_expanded_occurrences_view { query_with_no_match.count.must_equal 0 } }
      # it { with_occurrences_ordering_view { query.count.must_equal 1 } }
    end

    describe 'spanning multiple days' do
      let(:event) { build(:event, :today_until_tomorrow) }
      let(:query_dtstart) { today }
      let(:query_dtend) { today + 1.day }

      it { query.count.must_equal 1 }
      it { query_with_no_match.count.must_equal 0 }

      it { with_expanded_occurrences_view { query.count.must_equal 2 } }
      it { with_expanded_occurrences_view { query_with_no_match.count.must_equal 0 } }
      # it { with_occurrences_ordering_view { query.count.must_equal 1 } }
    end

    describe 'recurring' do
      let(:event) { build(:event, :recurring_daily_this_week) }
      let(:query_dtstart) { today + 2.days }
      let(:query_dtend) { query_dtstart + 5.day }

      it { query.count.must_equal 1 }
      it { query_with_no_match.count.must_equal 0 }

      it { with_expanded_occurrences_view { query.count.must_equal 5 } }
      it { with_expanded_occurrences_view { query_with_no_match.count.must_equal 0 } }
      # it { with_occurrences_ordering_view { query.count.must_equal 1 } }
    end

    private

    def with_occurrences_ordering_view(&block)
      Event.with_occurrences_ordering_view(&block)
    end

    def with_expanded_occurrences_view(&block)
      Event.with_expanded_occurrences_view(&block)
    end
  end

  describe 'Querying Parent with Embedded Events' do
    let(:klass) { EventParent }

    before { event_parent.save! }

    describe 'spanning one day' do
      let(:event_parent) { build(:event_parent, :today) }
      let(:query_dtstart) { today }
      let(:query_dtend) { today.end_of_day }

      it { query.count.must_equal 0 }
      it { query_with_no_match.count.must_equal 0 }

      it { with_expanded_occurrences_view { query.count.must_equal 1 } }
      it { with_expanded_occurrences_view { query_with_no_match.count.must_equal 0 } }
      # it { with_occurrences_ordering_view { query.count.must_equal 1 } }
    end

    describe 'spanning multiple days' do
      let(:event_parent) { build(:event_parent, :today_until_tomorrow) }
      let(:query_dtstart) { today }
      let(:query_dtend) { today + 1.day }

      it { query.count.must_equal 0 }
      it { query_with_no_match.count.must_equal 0 }

      it { with_expanded_occurrences_view { query.count.must_equal 2 } }
      it { with_expanded_occurrences_view { query_with_no_match.count.must_equal 0 } }
      # it { with_occurrences_ordering_view { query.count.must_equal 1 } }
    end

    describe 'recurring' do
      let(:event_parent) { build(:event_parent, :recurring_daily_this_week) }
      let(:query_dtstart) { today + 2.days }
      let(:query_dtend) { query_dtstart + 5.day }

      it { query.count.must_equal 0 }
      it { query_with_no_match.count.must_equal 0 }

      it { with_expanded_occurrences_view { query.count.must_equal 5 } }
      it { with_expanded_occurrences_view { query_with_no_match.count.must_equal 0 } }
      # it { with_occurrences_ordering_view { query.count.must_equal 1 } }
    end

    private

    def with_occurrences_ordering_view(&block)
      EventParent.with_occurrences_ordering_view(&block)
    end

    def with_expanded_occurrences_view(&block)
      EventParent.with_expanded_occurrences_view(&block)
    end
  end
end
