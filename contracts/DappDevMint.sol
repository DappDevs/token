pragma solidity ^0.4.21;

import "./DappDevToken.sol";

contract DappDevMint
{
  /* DappDevToken address */
  DappDevToken public token;

  /* address that have authority to change delegates */
  address public owner;

  /* addresses that have authority to mint */
  mapping (address => bool) public canMint;
  
  /* Event for minter access control */
  event AccessControl(address minter, bool granted);
  
  
  function DappDevMint(address _token)
    public
  {
    token = DappDevToken(_token);
    owner = msg.sender;
    canMint[msg.sender] = true;
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
   * @dev Function to mint tokens
   * @param _to The address that will receive the minted tokens.
   * @param _amount The amount of tokens to mint.
   */
  function mint(address _to, uint256 _amount)
    public
  {
      require(canMint[msg.sender]);
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
      canMint[newDelegate] = true;
      emit AccessControl(newDelegate, true);
  }

  /**
   * @dev Function remove existing minters/delegates
   * @param oldDelegate The address that will be removed
   */
   function removeDelegate(address oldDelegate) public {
      require(isOwner(msg.sender));
      canMint[oldDelegate] = false;
      emit AccessControl(oldDelegate, false);
  }


}
