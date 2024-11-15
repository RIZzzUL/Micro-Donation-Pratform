module MicroDonationPlatform::MicroDonation {
    use aptos_framework::signer;
    use aptos_framework::coin;
    use aptos_framework::aptos_coin::AptosCoin;
    use std::string::String;

    /// Struct representing a micro donation campaign
    struct Campaign has store, key {
        name: String,           // Campaign name
        description: String,    // Campaign description
        total_funds: u64,      // Total funds raised
        goal: u64,              // Funding goal
        creator: address,       // Campaign creator
        is_active: bool,        // Campaign active status
    }

    /// Create a new micro donation campaign
    public fun create_campaign(
        creator: &signer, 
        name: String, 
        description: String, 
        goal: u64
    ) {
        let campaign = Campaign {
            name,
            description,
            total_funds: 0,
            goal,
            creator: signer::address_of(creator),
            is_active: true,
        };
        move_to(creator, campaign);
    }

    /// Donate to an existing campaign
    public fun donate_to_campaign(
        donor: &signer, 
        campaign_creator: address, 
        amount: u64
    ) acquires Campaign {
        // Borrow the campaign
        let campaign = borrow_global_mut<Campaign>(campaign_creator);
        
        // Ensure campaign is still active
        assert!(campaign.is_active, 0);
        
        // Transfer donation
        coin::withdraw<AptosCoin>(donor, amount);
        coin::deposit<AptosCoin>(campaign_creator, amount);
        
        // Update total funds
        campaign.total_funds = campaign.total_funds + amount;
        
        // Automatically close campaign if goal is reached
        if (campaign.total_funds >= campaign.goal) {
            campaign.is_active = false;
        }
    }
}