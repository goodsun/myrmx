// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

abstract contract VirtualOwner {
    address private _virtualOwner;

    event VirtualOwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    modifier onlyVirtualOwner() {
        require(virtualOwner() == msg.sender, "VirtualOwner: caller is not the virtual owner");
        _;
    }

    constructor() {
        _transferVirtualOwnership(msg.sender);
    }

    function virtualOwner() public view virtual returns (address) {
        return _virtualOwner;
    }

    function renounceVirtualOwnership() public virtual onlyVirtualOwner {
        _transferVirtualOwnership(address(0));
    }

    function transferVirtualOwnership(address newOwner) public virtual onlyVirtualOwner {
        require(newOwner != address(0), "VirtualOwner: new owner is the zero address");
        _transferVirtualOwnership(newOwner);
    }

    function _transferVirtualOwnership(address newOwner) internal virtual {
        address oldOwner = _virtualOwner;
        _virtualOwner = newOwner;
        emit VirtualOwnershipTransferred(oldOwner, newOwner);
    }
}