require "rails_helper"

RSpec.describe IncidentUpdate do
  describe "associations" do
    it { is_expected.to belong_to(:incident) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:message) }
  end

  describe "enums" do
    it { is_expected.to define_enum_for(:status).with_values(investigating: 0, identified: 1, monitoring: 2, resolved: 3) }
  end
end
