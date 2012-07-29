Given a hardcoded board

* how to set up initial board state?

given a board and a current state

* how to update to next board state?

given a current state and a WASD input

 * how to update to next board state?
 * and note changed to removable count
 * and detect if poison/lava was consumed and put an X for player position

W: move player to current location - 0x08
A: move player to location -0x01

subroutine: valid player location check


given a board

* how to determine if game over?
* if there's an X
* "everything edible is eaten" removable counter reaches 0
* alt: "board scan for * and numbers" counts 0

once gameplay starts...

* move player
* update board

once game over...

* Report round number as (Golf) score
* Or report failure (straight out)

check if game over

maybe a menu to...

* play (again)
* show current board
* enter new board