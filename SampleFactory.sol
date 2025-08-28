// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

/// @title Product - 被克隆的逻辑合约
contract Product {
    address public owner;
    string public name;

    bool public initialized;

    /// 初始化函数，只能调用一次
    function initialize(address _owner, string memory _name) external {
        require(!initialized, "Already initialized");
        owner = _owner;
        name = _name;
        initialized = true;
    }
}

/// @title CloneLibrary - 用于创建最小代理合约 (EIP-1167)
library CloneLibrary {
    function clone(address implementation) internal returns (address instance) {
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x3d602d80600a3d3981f3)
            mstore(add(ptr, 0x14), shl(0x60, implementation))
            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf3)
            instance := create(0, ptr, 0x37)
        }
        require(instance != address(0), "Clone failed");
    }
}

/// @title Factory - 工厂合约（克隆 Product）
contract Factory {
    using CloneLibrary for address;

    address public immutable productImplementation;
    address[] public allProducts;

    event ProductCreated(address indexed productAddress, address indexed owner, string name);

    constructor() {
        // 部署一次 Product 逻辑合约
        productImplementation = address(new Product());
    }

    /// @notice 创建新的 Product 克隆
    function createProduct(string memory _name) external {
        address clone = productImplementation.clone();
        Product(clone).initialize(msg.sender, _name);

        allProducts.push(clone);
        emit ProductCreated(clone, msg.sender, _name);
    }

    /// @notice 获取所有已创建的 Product 地址
    function getAllProducts() external view returns (address[] memory) {
        return allProducts;
    }
}
