PAYEE_NAMES = ['Evil Corp. International', 'Shameless Astroturf, Inc.', 'News Corporation']

FactoryGirl.define do
    factory :candidate, :class => CampaignCash::Candidate do
        sequence(:id, 600000)
        sequence(:name) { |n| 'Candidate #{n}' }
        sequence(:party) { |n| n % 2 ? 'REP' : 'DEM' }
    end
    factory :expenditure, :class => CampaignCash::IndependentExpenditure do
        sequence(:id, 10000)
        amount 10000.0
        support_or_oppose 'S'
        sequence(:payee) { |n| PAYEE_NAMES[n % 3] }
    end
end
