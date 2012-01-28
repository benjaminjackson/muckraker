PAYEE_NAMES = ['Evil Corp. International', 'Shameless Astroturf, Inc.', 'News Corporation']

FactoryGirl.define do
    sequence :amount do |n|
        n * 100.0;
    end

    factory :candidate, :class => CampaignCash::Candidate do
        sequence(:id, "600000")
        sequence(:name) { |n| "Candidate #{n}" }
        sequence(:party) { |n| n % 2 ? 'REP' : 'DEM' }
    end
    factory :expenditure, :class => CampaignCash::IndependentExpenditure do
        sequence(:id, "10000")
        sequence(:amount) { |n| 100.0 * n }
        support_or_oppose 'S'
        sequence(:payee) { |n| PAYEE_NAMES[n % 3] }
        candidate "600000"
    end
end
