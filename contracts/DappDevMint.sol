pragma solidity ^0.4.19;

import "./DappDevToken.sol";

contract DappDevMint
{
  /* DappDevToken address */
  DappDevToken public token;

  /* address that have authority to change delegates */
  address public owner;

  /* addresses that have authority to mint */
  address[] public delegates;

  function DappDevMint(address _token)
    public
  {
    token = DappDevToken(_token);
    owner = msg.sender;
  }

  function acceptOwnership()
    public
  {
    token.acceptOwnership();
  }

  /**
   * @dev Modifier to check for access control rights
   * @param candidate The address to check for ownership access rights
   * @return A boolean that indicates if the candidate is an owner
   */
  function isOwner(address candidate)
    public
    view
    returns (bool)
  {
    if (candidate == owner)
      // Return true if candidate is owner
      return true;

    // Not an owner
    return false;
  }

  /**
   * @dev Modifier to check for access control rights
   * @param candidate The address to check for ownership access rights
   * @return A boolean that indicates if the candidate is a delegate
   */
  function isDelegate(address candidate)
    public
    view
    returns (bool)
  {
    // Search through delegates list
    for (uint i = 0; i < delegates.length; i++)
      if (candidate == delegates[i])
        // Return true if candidate is delegate
        return true;

    // Not an owner or delegate
    return false;
  }


  /**
   * @dev Function to mint tokens
   * @param _to The address that will receive the minted tokens.
   * @param minterIndex The index of the minter in the delegates array
   * @param _amount The amount of tokens to mint.
   */
  function mint(address _to, uint minterIndex, uint256 _amount)
    public
  {
      require(msg.sender == findByIndex(minterIndex));
      assert(token.mint(_to, _amount));
  }

  /**
   * @dev Function Change ownership on the faucet token
   * @param newOwner The address that will become the new owner
   */
   function transferTokenOwnership(address newOwner) public {
       require(isOwner(msg.sender));
       token.transferOwnership(newOwner);
   }


  /**
   * @dev Function add minters/delegates
   * @param newDelegate The address that will be allowed to mint tokens.
   */
   function addDelegate(address newDelegate) public {
      //only owner can add delegate
      require(isOwner(msg.sender));
      // don't add if already there
      if (!isDelegate(newDelegate))
         delegates.push(newDelegate);
  }

  /**
   * @dev Function remove existing minters/delegates
   * @param oldDelegate The address that will be removed
   */
   function removeDelegate(address oldDelegate) public {
      require(isOwner(msg.sender));
      require(isDelegate(oldDelegate));
      removeByValue(oldDelegate);
  }


    // helper functions for working with delegate array
    /**
     * @dev Function Find delegate by address
     * @param delegate Address to find
     */
    function find(address delegate) public constant returns(uint) {
        uint i = 0;
        while (delegates[i] != delegate && i < delegates.length) {
            i++;
        }
        return i; //@todo test and handle when address is NOT in array
    }

    /**
     * @dev Function return address based on index
     * @param index Index of delegate addresses to find
     * @return address The address of delegate at index
     */
    function findByIndex(uint index) private constant returns(address) {
        return delegates[index];
    }

    /**
     * @dev Function remove address delegate array by address
     * @param delegate Delegate address
     */
    function removeByValue(address delegate) private {
        uint i = find(delegate);
        removeByIndex(i);
    }

    /**
     * @dev Function remove from array by index removeByValue
     * @param i Index to removeByIndex
     */
    function removeByIndex(uint i) private {
        while (i<delegates.length-1) {
            delegates[i] = delegates[i+1];
            i++;
        }
        delegates.length--;
    }
}
