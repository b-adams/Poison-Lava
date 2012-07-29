# Game shell #
- Board entry: Remember only capital S and digits 0-9 are allowed on the static board. Everything else should be rejected (especially newlines, since that makes it much easier to enter a board, but rejecting "everything else" is easier than targeting just newlines)
- Board view: Only the first spot on the board is being displayed
- Typo - During board entry, there's no instruction on how to place the player's starting location
- Typo - Tiny formatting error on player-lose message
- Typo - The Icon Key you give is for the dynamic, rather than static, board.
- Note: While checking game over - "emergency catch" shouldn't be necessary but actually would have been handy in detecting a misplaced return value.


# Move player: #
- The high byte of function [NPplMove]'s return address is getting mangled
- when passed a 'w', comparison is made to 0x6677 instead of 0x77
- make sure to doublecheck -all- stack addresses after fixing previous issues
- Internal loop doesn't end with last space on board, but one after last space
- Nomming does not decrement the edible counter
- Lavawalking does not decrement the lives counter
-moving right from last position on board puts player off the board and into program memory [while it would be AWESOME to have a game where the player moves around in, and damages, the code of the program, that's not the current goal]
- location of player (playLoc) isn't updated
- size of letter C becomes small, but then stays small
- Player is being killed when moving onto an eaten/previously-visited (.) space. This should be allowed (and shouldn't accidentally change the edible counter once it's allowed)
