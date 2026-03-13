 # 🏂 Snowboard Race (Solidity Game)          
            
**Snowboard Race** is a fully on-chain, turn-based multiplayer game where players race down a snowy slope on snowboards. The game is implemented in pure Solidity, making every move verifiable, transparent, and trustless.  
               
---          
          
## ❄️ Gameplay Overview        
                
- 2–4 players per race           
- Each player takes turns "rolling a dice" (1–6)         
- First to reach the finish line wins         
- All logic is on-chain — no central control, no cheating         
          
---        
      
## 🧱 Built With       
        
- [Solidity](https://docs.soliditylang.org/) — core game logic         
- [Hardhat](https://hardhat.org/) *(recommended)* for testing/deployment       
- [Chainlink VRF](https://docs.chain.link/docs/vrf/v2/introduction/) *(optional)* for real randomness       
     
--- 
   
## 🎮 Game Flow     
  
1. **Create a race**    
    ```solidity      
    createGame(uint256 finishLine)   
    ```
 
2. **Join the race**
    ```solidity
    joinGame(uint256 gameId)
    ```

3. **Start racing**
    - Players take turns calling:
    ```solidity
    move(uint256 gameId, uint256 randomRoll)
    ```

4. **Win condition**
    - First to reach or exceed `finishLine` wins.

---

## 🔁 Example Turn

```solidity
// Player A rolls a 4
move(1, 4);

// Emits:
PlayerMoved(gameId=1, player=0xABC..., roll=4, newPosition=12)
