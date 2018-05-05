pragma solidity ^0.4.21;

library Addresses {
  function isContract(address _base) internal view returns (bool) {
      uint codeSize;
      assembly {
          codeSize := extcodesize(_base)
      }
      return codeSize > 0;
  }
}