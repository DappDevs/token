pragma solidity ^0.4.19;

import "./DappDevToken.sol";

contract DappDevMint
{
  /* DappDevToken address */
  DappDevToken public token;

  /* addresses that have authority to mint and change delegates */
  address[] public owners;

  /* addresses that have authority to mint */
  address[] public delegates;

  struct Proposal {
      mapping(address => bool) proposed;
      uint yayVotes;
      uint nayVotes;
  }

  mapping(address => Proposal) newMintProposals;
  mapping(address => Proposal) newDelegateProposals;

  function DappDevMint(address _token)
    public
  {
    token = DappDevToken(_token);
    owners.push(msg.sender);
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
    // Search through owners list
    for (uint i = 0; i < owners.length; i++)
      if (candidate == owners[i])
        // Return true if candidate is owner
        return true;

    // Not an owner
    return false;
  }

  /**
   * @dev Modifier to check for access control rights
   * @param candidate The address to check for ownership access rights
   * @return A boolean that indicates if the candidate is an owner
   */
  function isOwnerOrDelegate(address candidate)
    public
    view
    returns (bool)
  {
    // Check if an owner first
    if (isOwner(candidate))
      return true;

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
   * @param _amount The amount of tokens to mint.
   */
  function mint(address _to, uint256 _amount)
    public
  {
      require(isOwnerOrDelegate(msg.sender));
      assert(token.mint(_to, _amount));
  }

  function voteNewDelegate(address newDelegate, bool yayVote)
    public
  {
    require(isOwner(msg.sender));
    // Sender hasn't already proposed this
    require(!newDelegateProposals[newDelegate].proposed[msg.sender]);
    // Add votes for this proposal
    newDelegateProposals[newDelegate].proposed[msg.sender] = true;
    if (yayVote)
    {
      newDelegateProposals[newDelegate].yayVotes += 1;
      // If majority votes to accept this, add to delegates and remove this
      if (newDelegateProposals[newDelegate].yayVotes > owners.length/2)
      {
        delegates.push(newDelegate);
        delete newDelegateProposals[newDelegate];
      }
    }
    else
    {
      newDelegateProposals[newDelegate].nayVotes += 1;
      // If majority votes to reject this, remove from proposals
      if (newDelegateProposals[newDelegate].nayVotes > owners.length/2)
      {
        delete newDelegateProposals[newDelegate];
      }
    }
  }

  function voteNewTokenMint(address newMint, bool yayVote)
    public
  {
    require(isOwner(msg.sender));
    // Sender hasn't already proposed this
    require(!newMintProposals[newMint].proposed[msg.sender]);
    // Add votes for this proposal
    newMintProposals[newMint].proposed[msg.sender] = true;
    if (yayVote)
    {
      newMintProposals[newMint].yayVotes += 1;
      // If majority votes to accept this, transfer ownership of token to that address, and destroy this one
      if (newMintProposals[newMint].yayVotes > owners.length/2)
      {
        token.transferOwnership(newMint);
        selfdestruct(newMint);
      }
    }
    else
    {
      newMintProposals[newMint].nayVotes += 1;
      // If majority votes to reject this, remove from proposals
      if (newMintProposals[newMint].nayVotes > owners.length/2)
      {
        delete newMintProposals[newMint];
      }
    }
  }
}
