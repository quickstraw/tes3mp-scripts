## Bounty Board
Adds a bounty command which displays a sorted list of active players and their bounties.

![Imgur](https://i.imgur.com/QaEMkjF.png)

### Installation
Add:  
```
elseif cmd[1] == "bounties" then
	bountyBoard.DisplayBounties(pid)
```
to the command chain in commandHandler.lua.
