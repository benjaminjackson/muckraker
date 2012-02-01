PAYEE_NAMES = ['Evil Corp. International', 'Shameless Astroturf, Inc.', 'News Corporation']
COMMITTEE_NAMES = ['Elect Barack Obama', 'Campaign to Defeat Mitt Romney', 'Super PAC']

FactoryGirl.define do
    sequence :amount do |n|
        n * 100.0;
    end

    factory :candidate, :class => CampaignCash::Candidate do
        sequence(:id, "600000")
        sequence(:name) { |n| "Candidate #{n}" }
        sequence(:party) { |n| n % 2 ? 'REP' : 'DEM' }
        sequence(:committee_id, "C400000")
        office "house"
    end

    factory :expenditure, :class => CampaignCash::IndependentExpenditure do
        sequence(:id, "10000")
        sequence(:committee_name) { |n| COMMITTEE_NAMES[n % 3] }
        sequence(:committee_id, "C10000")
        sequence(:amount) { |n| 100.0 * n }
        support_or_oppose 'S'
        sequence(:payee) { |n| PAYEE_NAMES[n % 3] }
        candidate "600000"
    end
end
