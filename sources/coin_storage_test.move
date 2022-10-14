#[test_only]
module coin_storage::storage_tests {
    use aptos_std::signer;
    use aptos_std::account;
    use aptos_std::string;

    use aptos_std::coin;
    use coin_storage::coin_storage;

    #[test_only]
    struct FakeMoney {}


    #[test_only]
    fun generate_fake_money(account: &signer) {
        let account_addr = signer::address_of(account);

        let (burn_cap, freeze_cap, mint_cap) = coin::initialize<FakeMoney>(
            account,
            string::utf8(b"Fake money"),
            string::utf8(b"FMD"),
            8,
            false
        );

        let coins_minted = coin::mint<FakeMoney>(100, &mint_cap);
        coin::register<FakeMoney>(account);
        coin::deposit<FakeMoney>(account_addr, coins_minted);

        coin::destroy_freeze_cap<FakeMoney>(freeze_cap);
        coin::destroy_burn_cap<FakeMoney>(burn_cap);
        coin::destroy_mint_cap<FakeMoney>(mint_cap);
    }

    #[test(source = @coin_storage)]
    public entry fun normal_flow(source: signer) {
        let account = &source;
        let account_addr = signer::address_of(account);

        account::create_account_for_test(account_addr);

        generate_fake_money(account);
        assert!(coin_storage::balance<FakeMoney>(account_addr) == 0, 0);
        assert!(coin::balance<FakeMoney>(account_addr) == 100, 0);

        coin_storage::deposit<FakeMoney>(account, 10);
        assert!(coin_storage::balance<FakeMoney>(account_addr) == 10, 0);
        assert!(coin::balance<FakeMoney>(account_addr) == 90, 0);

        coin_storage::deposit<FakeMoney>(account, 5);
        assert!(coin_storage::balance<FakeMoney>(account_addr) == 15, 0);
        assert!(coin::balance<FakeMoney>(account_addr) == 85, 0);

        coin_storage::withdraw<FakeMoney>(account, 10);
        assert!(coin_storage::balance<FakeMoney>(account_addr) == 5, 0);
        assert!(coin::balance<FakeMoney>(account_addr) == 95, 0);

        coin_storage::withdraw<FakeMoney>(account, 5);
        assert!(coin_storage::balance<FakeMoney>(account_addr) == 0, 0);
        assert!(coin::balance<FakeMoney>(account_addr) == 100, 0);
    }

    #[test(source = @coin_storage)]
    #[expected_failure(abort_code = 0x60002)]
    public entry fun withdraw_with_no_account(source: signer) {
        let account = &source;
        let account_addr = signer::address_of(account);

        account::create_account_for_test(account_addr);

        generate_fake_money(account);

        coin_storage::withdraw<FakeMoney>(account, 5);
    }

    #[test(source = @coin_storage)]
    #[expected_failure(abort_code = 0x10003)]
    public entry fun withdraw_with_insufficient_funds(source: signer) {
        let account = &source;
        let account_addr = signer::address_of(account);

        account::create_account_for_test(account_addr);

        generate_fake_money(account);

        coin_storage::deposit<FakeMoney>(account, 5);
        coin_storage::withdraw<FakeMoney>(account, 10);
    }
}