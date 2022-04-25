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

    function setAsksAndBidsList() public {
        for (uint256 i = 0; i < sellers.length; i++) {
            Asks.push(sellers[i]);
        }

        quickSort("asc", Asks, 0, int256(Asks.length - 1));
        // for (uint256 i = 0; i < Asks.length; i++) {
        //     Asks[i].price = 0 - Asks[i].price;
        // }

        for (uint256 i = 0; i < buyers.length; i++) {
            Bids.push(buyers[i]);
        }
        quickSort("asc", Bids, 0, int256(Bids.length - 1));
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

    function getQFunction() public {
        qMin = 0;
        Participant memory a;
        Participant memory b;

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
        int256 sellersQuantity = 0;
        for (uint256 i = 0; i < sellers.length; i++) {
            sellersQuantity -= sellers[i].quantity;
        }
        sellersQuantity += qMin;

        // Match
        for (uint256 i = 0; i < sellers.length; i++) {
            Asks.push(sellers[i]);
        }

        quickSort("desc", Asks, 0, int256(Asks.length - 1));

        for (uint256 i = 0; i < buyers.length; i++) {
            Bids.push(buyers[i]);
        }
        quickSort("desc", Bids, 0, int256(Bids.length - 1));

        Participant memory a;
        Participant memory b;
        int256 tempBalance = 0;
        int256 tempQuantity = 0;
        bool temp4seller = true;

        b = poll("buyer");
        if (b.price != 0 && b.quantity != 0) {
            a = poll("seller");

            while (sellersQuantity + a.quantity < 0) {
                sellersQuantity += a.quantity;
                pushResult(a.addr, "seller", a.quantity, 0);
                a = poll("seller");
            }

            a.quantity += sellersQuantity;

            while (b.price != 0 && b.quantity != 0) {
                if (a.price == 0 && a.quantity == 0) {
                    pushResult(
                        b.addr,
                        "buyer",
                        tempQuantity + b.quantity,
                        0 - (tempBalance + b.quantity * gridPrice)
                    );
                    tempQuantity = 0;
                    tempBalance = 0;
                    b = poll("buyer");
                } else if (a.quantity < b.quantity) {
                    if (temp4seller) {
                        pushResult(
                            a.addr,
                            "seller",
                            0 - (tempQuantity + a.quantity),
                            tempBalance + a.quantity * a.price
                        );
                        tempQuantity = a.quantity;
                        tempBalance = a.quantity * a.price;
                    } else {
                        pushResult(
                            a.addr,
                            "seller",
                            0 - a.quantity,
                            a.quantity * a.price
                        );
                        tempQuantity += a.quantity;
                        tempBalance += a.quantity * a.price;
                    }
                    temp4seller = false;
                    b.quantity -= a.quantity;
                    a = poll("seller");
                } else if (a.quantity > b.quantity) {
                    if (!temp4seller) {
                        pushResult(
                            b.addr,
                            "buyer",
                            tempQuantity + b.quantity,
                            0 - (tempBalance + b.quantity * a.price)
                        );
                        tempQuantity = b.quantity;
                        tempBalance = b.quantity * a.price;
                    } else {
                        pushResult(
                            b.addr,
                            "buyer",
                            b.quantity,
                            0 - (b.quantity * a.price)
                        );
                        tempQuantity += b.quantity;
                        tempBalance += b.quantity * a.price;
                    }
                    temp4seller = true;
                    a.quantity -= b.quantity;
                    b = poll("buyer");
                } else {
                    if (temp4seller) {
                        pushResult(
                            a.addr,
                            "seller",
                            0 - (tempQuantity + a.quantity),
                            tempBalance + a.quantity * a.price
                        );
                        pushResult(
                            b.addr,
                            "buyer",
                            b.quantity,
                            0 - (b.quantity * a.price)
                        );
                    } else {
                        pushResult(
                            a.addr,
                            "seller",
                            0 - a.quantity,
                            a.quantity * a.price
                        );
                        pushResult(
                            b.addr,
                            "buyer",
                            tempQuantity + b.quantity,
                            0 - (tempBalance + b.quantity * a.price)
                        );
                    }
                    temp4seller = true;
                    tempQuantity = 0;
                    tempBalance = 0;
                    a = poll("seller");
                    b = poll("buyer");
                }
            }
        }
    }

    function getResults() public view returns (Result[] memory) {
        return results;
    }

    function pushResult(
        address addr,
        string memory role,
        int256 quantity,
        int256 balance
    ) internal {
        Result memory result;

        result.addr = addr;
        result.role = role;
        result.quantity = quantity;
        result.balance = balance;
        results.push(result);
    }

    function reset() public {
        delete sellers;
        delete buyers;
        delete results;
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
}
