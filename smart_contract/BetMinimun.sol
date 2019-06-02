pragma solidity >=0.4.99;
contract BetMinimun {
    address payable public owner;
    uint256 public minimumBet;
    uint256 public total_pool;
    uint256 public numbers_region = 5;
    uint256[] pools_counting;
    uint256[] pools_amount;
    uint256 public prevWinNumber = 0;
    address payable[] public players;
    struct Player {
      uint256 amountBet;
      uint16 numberSelected;
    }
    // The address of the player and => the user info
    mapping(address => Player) playerInfo;
    function() external payable {}
   
    constructor() public {
        owner = msg.sender;
        // minimumBet = 100000000000000;
        minimumBet = 1000000000000;
        pools_counting.length = numbers_region;
        pools_amount.length = numbers_region;
    }
    // function kill() public {
    //   if(msg.sender == owner) selfdestruct(owner);
    // }
    function refundToAll() public {
        for(uint256 i = 0; i < players.length; i++){
            players[i].transfer(playerInfo[ players[i]].amountBet);
        }
    }
    
    function checkPlayerExists(address payable player) public view returns(bool){
        for(uint256 i = 0; i < players.length; i++){
            if(players[i] == player) return true;
        }
        return false;
    }
    function bet(uint8 _numberSelected) public payable {
        require(!checkPlayerExists(msg.sender));
        require(msg.value >= minimumBet);
        if(_numberSelected<0 || _numberSelected>pools_counting.length-1 ) {
            msg.sender.transfer(msg.value);
            return;
        }
        playerInfo[msg.sender].amountBet = msg.value;
        playerInfo[msg.sender].numberSelected = _numberSelected;
        players.push(msg.sender);
        
        pools_counting[_numberSelected]  += 1;
        pools_amount[_numberSelected]  += msg.value;
        total_pool += msg.value;
    }
    // Generates a number between 1 and 10 that will be the winner
    function distributePrizes() public payable {
      address payable[1000] memory winners;
        //We have to create a temporary in memory array with fixed size
        //Let's choose 1000
        uint256 winner_count = 0; // This is the count for the array of winners
        address add;
        
        // find mininum pool and its amount
        uint256 mininum_point = 0;
        uint256 mininum_num = 0;
        for(uint256 i = 0; i < pools_counting.length; i++){
            if(pools_counting[i] == 0) continue;
            if (mininum_point == 0) {
                mininum_num = i;
                mininum_point = pools_counting[i];
            }
            else if(pools_counting[i]<=mininum_point && pools_counting[i] != 0) {
                mininum_num = i;
                mininum_point = pools_counting[i];
            }
        }
        if(mininum_point == 0) {
            return;
        }
        address payable playerAddress;
        
        //We loop through the player array find winners
        
        for(uint256 i = 0; i < players.length; i++){
         playerAddress = players[i];
        //If the player selected the winner team
         //We add his address to the winners array
         if(playerInfo[playerAddress].numberSelected == mininum_num){
            winners[winner_count] = playerAddress;
            winner_count++;
         }
        }
        if (winner_count == players.length) {
            refundToAll();
            return;
        }
        //sperate total pool and transfer to winners
        for(uint256 j = 0; j < winner_count; j++){
         if(winners[j] != address(0))
            add = winners[j];
            uint256 bet = playerInfo[add].amountBet;
            winners[j].transfer(total_pool*(bet/pools_amount[mininum_num]));
            // winners[j].transfer(bet);
        
        }
        
        // reset lottery
        players.length = 0; // Delete all the players arra
        total_pool = 0;
        prevWinNumber = mininum_num;
        delete playerInfo[playerAddress]; // Delete all the players
        delete pools_counting;
        delete pools_amount;
        pools_counting.length = numbers_region;
        pools_amount.length = numbers_region;
    }
}