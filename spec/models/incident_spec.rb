require "rails_helper"

RSpec.describe Incident do
  describe "associations" do
    it { is_expected.to have_many(:incident_updates).dependent(:destroy) }
    it { is_expected.to have_and_belong_to_many(:site_monitors) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:title) }
  end

  describe "enums" do
    it { is_expected.to define_enum_for(:status).with_values(investigating: 0, identified: 1, monitoring: 2, resolved: 3) }
    it { is_expected.to define_enum_for(:severity).with_values(minor: 0, major: 1, critical: 2) }
  end

  describe "scopes" do
    let!(:active_incident) { create(:incident, :investigating) }
    let!(:resolved_incident) { create(:incident, :resolved) }

    describe ".active" do
      it "returns non-resolved incidents" do
        expect(described_class.active).to contain_exactly(active_incident)
      end
    end

    describe ".resolved" do
      it "returns resolved incidents" do
        expect(described_class.resolved).to contain_exactly(resolved_incident)
      end
    end

    describe ".recent" do
      it "returns incidents ordered by most recent, limited" do
        expect(described_class.recent(1).count).to eq(1)
      end
    end
  end

  describe "#resolve!" do
    let(:incident) { create(:incident, :investigating) }

    it "marks the incident as resolved" do
      incident.resolve!

      expect(incident.reload).to be_resolved
    end

    it "sets the resolved_at timestamp" do
      freeze_time do
        incident.resolve!

        expect(incident.reload.resolved_at).to eq(Time.current)
      end
    end
  end
end
