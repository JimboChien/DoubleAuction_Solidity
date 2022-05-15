// SPDX-License-Identifier: MIT
pragma experimental ABIEncoderV2;
pragma solidity >=0.4.21 <8.10.0;

import "./Role.sol";

contract DoubleAuction is Role {
    Participant[] public sellers;
    Participant[] public buyers;
    Participant[] public Asks;
    Participant[] public Bids;
    Result[] public results;
    int256 gridPrice = 800;
    Statistics public statistics;

    function joinAuction(
        string memory _role,
        int256 _quantity,
        int256 _price
    ) public {
        Participant memory temp;
        temp.addr = msg.sender;
        temp.quantity = _quantity;
        temp.price = _price;
        if (keccak256(bytes(_role)) == keccak256(bytes("seller"))) {
            sellers.push(temp);
        } else if (keccak256(bytes(_role)) == keccak256(bytes("buyer"))) {
            buyers.push(temp);
        }
    }

    function getSellerPerference()
        public
        view
        returns (int256 quantity, int256 price)
    {
        for (uint256 i = 0; i < sellers.length; i++) {
            if (sellers[i].addr == msg.sender) {
                return (sellers[i].quantity, sellers[i].price);
            }
        }
    }

    function getBuyerPerference()
        public
        view
        returns (int256 quantity, int256 price)
    {
        for (uint256 i = 0; i < buyers.length; i++) {
            if (buyers[i].addr == msg.sender) {
                return (buyers[i].quantity, buyers[i].price);
            }
        }
    }

    function getSellerList() public view returns (Participant[] memory) {
        return sellers;
    }

    function getSeller() public returns (Participant memory) {
        for (uint256 i = 0; i < sellers.length; i++) {
            Asks.push(sellers[i]);
        }
    }

    function getBuyerList() public view returns (Participant[] memory) {
        return buyers;
    }

    function getAsksList() public view returns (Participant[] memory) {
        return Asks;
    }

    function getBidsList() public view returns (Participant[] memory) {
        return Bids;
    }

    function sortingAlgorithm()
        public
        returns (Participant[] memory, Participant[] memory)
    {
        quickSort("asc", sellers, 0, int256(sellers.length - 1));
        quickSort("asc", buyers, 0, int256(buyers.length - 1));

        return (sellers, buyers);
    }

    function setAsksAndBidsList(string memory _method) public {
        delete Asks;
        for (uint256 i = 0; i < sellers.length; i++) {
            Asks.push(sellers[i]);
        }

        quickSort(_method, Asks, 0, int256(Asks.length - 1));

        delete Bids;
        for (uint256 i = 0; i < buyers.length; i++) {
            Bids.push(buyers[i]);
        }
        quickSort(_method, Bids, 0, int256(Bids.length - 1));
    }

    function quickSort(
        string memory _mode,
        Participant[] storage arr,
        int256 left,
        int256 right
    ) internal {
        int256 i = left;
        int256 j = right;
        if (i == j) return;
        int256 pivot = arr[uint256(left + (right - left) / 2)].price;
        while (i <= j) {
            if (keccak256(bytes(_mode)) == keccak256(bytes("asc"))) {
                while (arr[uint256(i)].price < pivot) i++;
                while (pivot < arr[uint256(j)].price) j--;
            } else if (keccak256(bytes(_mode)) == keccak256(bytes("desc"))) {
                while (arr[uint256(i)].price > pivot) i++;
                while (pivot > arr[uint256(j)].price) j--;
            }
            if (i <= j) {
                Participant memory temp;
                temp = arr[uint256(i)];
                arr[uint256(i)] = arr[uint256(j)];
                arr[uint256(j)] = temp;

                i++;
                j--;
            }
        }
        if (left < j) quickSort(_mode, arr, left, j);
        if (i < right) quickSort(_mode, arr, i, right);
    }

    int256 qMin;
    int256 totalSellersQuantity;

    function getQFunction() public {
        Participant memory a;
        Participant memory b;

        setAsksAndBidsList("asc");

        a = poll("seller");
        if (a.price != 0 && a.quantity != 0) {
            b = poll("buyer");

            while (b.price != 0 && b.quantity != 0 && b.price < a.price) {
                b = poll("buyer");
            }

            // qd: Will Be The Demand at Price 0
            int256 qd = 0;
            // q: Current Horizontal Distance Between The Flipped Supply and The Demand Curves (Minus The Final Value of qd, Which is Unknow at Present).
            int256 q = 0;

            while (b.price != 0 && b.quantity != 0) {
                if (a.price != 0 && a.quantity != 0 && a.price <= b.price) {
                    q += a.quantity;
                    a = poll("seller");
                } else {
                    q -= b.quantity;
                    qMin = min(qMin, q);
                    qd += b.quantity;
                    b = poll("buyer");
                }
            }

            qMin += qd;
        }
    }

    function getQmv() public view returns (int256) {
        return qMin;
    }

    function getShift() public {
        totalSellersQuantity = qMin;
        // Match
        for (uint256 i = 0; i < sellers.length; i++) {
            totalSellersQuantity -= sellers[i].quantity;
        }

        setAsksAndBidsList("desc");

        Participant memory a;
        Participant memory b;
        bool temp4seller = true;

        a = poll("seller");
        b = poll("buyer");

        while (totalSellersQuantity + a.quantity < 0) {
            totalSellersQuantity += a.quantity;
            a = poll("seller");
        }

        a.quantity += totalSellersQuantity;

        while (b.price != 0 && b.quantity != 0) {
            if (a.price == 0 && a.quantity == 0) {
                break;
            } else if (a.quantity < b.quantity) {
                pushResult(b.addr, a.addr, a.quantity, a.price);

                temp4seller = false;
                b.quantity -= a.quantity;
                a = poll("seller");
            } else if (a.quantity > b.quantity) {
                pushResult(b.addr, a.addr, b.quantity, a.price);

                temp4seller = true;
                a.quantity -= b.quantity;
                b = poll("buyer");
            } else {
                pushResult(b.addr, a.addr, a.quantity, a.price);

                temp4seller = true;
                a = poll("seller");
                b = poll("buyer");
            }
        }

        int256 total_quantity = 0;
        int256 total_balance = 0;
        for (uint256 i = 0; i < results.length; i++) {
            total_quantity += results[i].quantity;
            total_balance += results[i].quantity * results[i].price;
        }

        statistics.avg = total_balance / total_quantity;
        statistics.max = results[0].price;
        statistics.min = results[results.length - 1].price;
    }

    function getResults() public view returns (Result[] memory) {
        return results;
    }

    function getStatistics() public view returns (Statistics memory) {
        return statistics;
    }

    function settlement() public {
        for (uint256 i = 0; i < results.length; i++) {
            uint256 total = uint256(results[i].quantity * results[i].price);

            balances[results[i].buyer] -= total;
            balances[results[i].seller] += total;
        }
    }

    function pushResult(
        address _buyer,
        address _seller,
        int256 _quantity,
        int256 _price
    ) internal {
        Result memory result;

        result.buyer = _buyer;
        result.seller = _seller;
        result.quantity = _quantity;
        result.price = _price;
        results.push(result);
    }

    function reset() public {
        delete sellers;
        delete buyers;
        delete results;
        delete statistics;
        delete Asks;
        delete Bids;
        qMin = 0;
        for (uint256 i = 0; i < allAddress.length; i++) {
            balances[allAddress[i]] = 0;
        }
    }

    function isEmpty(string memory _role) public view returns (bool) {
        if (keccak256(bytes(_role)) == keccak256(bytes("seller"))) {
            if (Asks.length == 0) {
                return true;
            } else {
                return false;
            }
        } else if (keccak256(bytes(_role)) == keccak256(bytes("buyer"))) {
            if (Bids.length == 0) {
                return true;
            } else {
                return false;
            }
        }
    }

    function poll(string memory _role) public returns (Participant memory) {
        Participant memory temp;
        if (keccak256(bytes(_role)) == keccak256(bytes("seller"))) {
            if (isEmpty("seller")) {
                temp.addr = 0x111122223333444455556666777788889999aAaa;
                temp.price = 0;
                temp.quantity = 0;
            } else {
                temp = Asks[0];
                for (uint256 i = 0; i < Asks.length - 1; i++) {
                    Asks[i] = Asks[i + 1];
                }
                delete Asks[Asks.length - 1];
                Asks.pop();
            }
        } else if (keccak256(bytes(_role)) == keccak256(bytes("buyer"))) {
            if (isEmpty("buyer")) {
                temp.addr = 0x111122223333444455556666777788889999aAaa;
                temp.price = 0;
                temp.quantity = 0;
            } else {
                temp = Bids[0];
                for (uint256 i = 0; i < Bids.length - 1; i++) {
                    Bids[i] = Bids[i + 1];
                }
                delete Bids[Bids.length - 1];
                Bids.pop();
            }
        }

        return temp;
    }

    function min(int256 a, int256 b) internal pure returns (int256) {
        return a <= b ? a : b;
    }

    // =================================================================
    // |                             Token                             |
    // =================================================================

    string public constant name = "Energy Token";
    string public constant symbol = "ENG";
    uint8 public constant decimals = 0;

    constructor() public {
        balances[msg.sender] = 0;
    }

    event Approval(
        address indexed tokenOwner,
        address indexed spender,
        uint256 tokens
    );
    event Transfer(address indexed from, address indexed to, uint256 tokens);

    mapping(address => uint256) balances;
    address[] allAddress;

    mapping(address => mapping(address => uint256)) allowed;

    // uint256 totalSupply_;

    using SafeMath for uint256;

    // function totalSupply() public view returns (uint256) {
    //     return totalSupply_;
    // }

    function balanceOf(address tokenOwner) public view returns (uint256) {
        return balances[tokenOwner];
    }

    function transfer(address receiver, uint256 numTokens)
        public
        returns (bool)
    {
        require(numTokens <= balances[msg.sender]);
        balances[msg.sender] = balances[msg.sender].sub(numTokens);
        balances[receiver] = balances[receiver].add(numTokens);
        emit Transfer(msg.sender, receiver, numTokens);
        return true;
    }

    function approve(address delegate, uint256 numTokens)
        public
        returns (bool)
    {
        allowed[msg.sender][delegate] = numTokens;
        emit Approval(msg.sender, delegate, numTokens);
        return true;
    }

    function allowance(address owner, address delegate)
        public
        view
        returns (uint256)
    {
        return allowed[owner][delegate];
    }

    function transferFrom(
        address owner,
        address buyer,
        uint256 numTokens
    ) public returns (bool) {
        require(numTokens <= balances[owner]);
        require(numTokens <= allowed[owner][msg.sender]);

        balances[owner] = balances[owner].sub(numTokens);
        allowed[owner][msg.sender] = allowed[owner][msg.sender].sub(numTokens);
        balances[buyer] = balances[buyer].add(numTokens);
        emit Transfer(owner, buyer, numTokens);
        return true;
    }

    function deposit() public payable {
        uint256 numTokens = msg.value;
        balances[msg.sender] += numTokens;
        allAddress.push(msg.sender);
    }

    function withdraw() public {
        msg.sender.transfer(balances[msg.sender]);
        balances[msg.sender] = 0;
    }
}

library SafeMath {
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}
