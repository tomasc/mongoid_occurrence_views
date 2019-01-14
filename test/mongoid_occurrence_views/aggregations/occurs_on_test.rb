require 'test_helper'

describe MongoidOccurrenceViews::Aggregations::OccursOn do
  let(:occurrence_today) { build(:occurrence, :today) }
  let(:occurrence_tomorrow) { build(:occurrence, :tomorrow) }
  let(:event) { build :event, occurrences: [occurrence_today, occurrence_tomorrow] }

  before { event.save! }

  it { subject.new(Event.criteria, occurrence_today.dtstart.to_date).instantiate.size.must_equal 1 }
  it { subject.new(Event.criteria, occurrence_today.dtstart.to_date).instantiate.must_include event }

  it { subject.new(Event.criteria, occurrence_tomorrow.dtstart.to_date).instantiate.size.must_equal 1 }
  it { subject.new(Event.criteria, occurrence_tomorrow.dtstart.to_date).instantiate.must_include event }

  it { subject.new(Event.criteria, occurrence_tomorrow.dtstart.to_date + 1.day).instantiate.wont_include event }

  describe 'dtstart & dtend' do
    let(:instantiated_event_today) { subject.new(Event.criteria, occurrence_today.dtstart).instantiate[0] }
    let(:instantiated_event_tomorrow) { subject.new(Event.criteria, occurrence_tomorrow.dtstart).instantiate[0] }

    it { instantiated_event_today.dtstart.must_equal occurrence_today.dtstart }
    it { instantiated_event_today.dtend.must_equal occurrence_today.dtend }

    it { instantiated_event_tomorrow.dtstart.must_equal occurrence_tomorrow.dtstart }
    it { instantiated_event_tomorrow.dtend.must_equal occurrence_tomorrow.dtend }
  end
end
