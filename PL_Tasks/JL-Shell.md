# When game starts: #
* Present user with a menu
* Play current board
* View current board
* Enter new board

# To Play current board: #
* keep (local) track of round number
* initialize round to 0
* set up dynamic board and initialize counter for edibles and life/lives (Gilian)
* Enter Gameplay Loop
* Report win/loss and, for win, round-based golf score
* Return to main menu

# Gameplay Loop: #
* Get a valid WASD user input
* Update round number
* Move player (Neale)
* Update board elements
* Exit loop if game over

# To View current board: #
* Read static board from memory and put in terminal output

# To Enter new board: #
* Get stuff from terminal input and put in static board 
