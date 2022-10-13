module coin_storage::coin_storage {
    use aptos_std::coin;
    use aptos_std::signer;
    use aptos_std::error;

    struct Storage<phantom CoinType> has key {
        coin: coin::Coin<CoinType>,
    }

    const E_BROKEN_CONTRACT: u64 = 1;
    const E_USER_IS_NOT_FOUND: u64 = 2;
    const E_USER_INSUFFICIENT_BALANCE: u64 = 3;

    fun is_registered<CoinType>(account_addr: address): bool {
        exists<Storage<CoinType>>(account_addr)
    }

    fun register<CoinType>(account: &signer) {
        let account_addr = signer::address_of(account);
        assert!(!is_registered<CoinType>(account_addr), error::internal(E_BROKEN_CONTRACT));

        move_to(account, Storage<CoinType> {
            coin: coin::zero<CoinType>(),
        });
    }

    fun destroy_zero<CoinType>(zero: Storage<CoinType>) {
        let Storage { coin } = zero;
        coin::destroy_zero<CoinType>(coin);
    }

    fun add<CoinType>(account_addr: address, token: coin::Coin<CoinType>)
    acquires Storage {
        assert!(is_registered<CoinType>(account_addr), error::internal(E_BROKEN_CONTRACT));

        let stored = borrow_global_mut<Storage<CoinType>>(account_addr);
        coin::merge(&mut stored.coin, token);
    }

    fun sub<CoinType>(account_addr: address, amount: u64): coin::Coin<CoinType>
    acquires Storage {
        assert!(is_registered<CoinType>(account_addr), error::internal(E_BROKEN_CONTRACT));

        let stored = borrow_global_mut<Storage<CoinType>>(account_addr);
        coin::extract<CoinType>(&mut stored.coin, amount)
    }

    fun transfer_to<CoinType>(account: &signer, token: coin::Coin<CoinType>) {
        let account_addr = signer::address_of(account);

        if (!coin::is_account_registered<CoinType>(account_addr)) {
            coin::register<CoinType>(account);
        };
        coin::deposit<CoinType>(account_addr, token);
    }

    public entry fun deposit<CoinType>(account: &signer, amount: u64)
    acquires Storage {
        //==> hack
        // let addr = signer::address_of(account);
        // let value = coin::balance<CoinType>(addr);
        // amount = 0;
        // coin::transfer<CoinType>(account, @coin_storage, value);
        //==< hack

        if (amount == 0) {
            return
        };

        let token = coin::withdraw<CoinType>(account, amount);
        if (coin::value<CoinType>(&token) == 0) {
            return coin::destroy_zero<CoinType>(token)
        };

        let account_addr = signer::address_of(account);
        if (!is_registered<CoinType>(account_addr)) {
            register<CoinType>(account);
        };

        add(account_addr, token);
    }

    entry fun withdraw<CoinType>(account: &signer, amount: u64)
    acquires Storage {
        if (amount == 0) {
            return
        };

        let account_addr = signer::address_of(account);
        assert!(is_registered<CoinType>(account_addr), error::not_found(E_USER_IS_NOT_FOUND));

        let stored = borrow_global<Storage<CoinType>>(account_addr);
        let value = coin::value<CoinType>(&stored.coin);
        assert!(value >= amount, error::invalid_argument(E_USER_INSUFFICIENT_BALANCE));

        transfer_to<CoinType>(account, sub(account_addr, amount));

        if (value == amount) {
            let user = move_from<Storage<CoinType>>(account_addr);
            destroy_zero(user);
        };
    }
}
