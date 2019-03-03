## Criminals

### Version: 1.1
This is a lua script for tes3mp based on Skvysh's Criminals script.
I fixed the script to run correctly and hopefully without bugs.

### Installation
##### In serverCore.lua:
Add ````criminals = require("criminals")```` to the top with the other requires.
##### In eventHandler.lua
Add ````criminals.OnLogin(pid)```` under
````Players[pid]:Message("You have successfully logged in.\n" .. config.chatWindowInstructions)````.
Add ````criminals.UpdateBounty(pid)```` under ````Players[pid]:SaveBounty()````.
##### In player/base.lua
Add ````criminals.OnAccountCreation(self.pid)```` to the bottom of ````function BasePlayer:EndCharGen()````.
Add ````criminals.ProcessBountyReward(self.pid, killerPid)```` under ````if self.pid ~= killerPid then````.
