;Constants 
boardL: .equate 8  ;board length
boardW: .equate 8  ;board width
boardE: .equate 64 ;number of elements

gameNovr: .equate 42 ;Aly return code: Game not over
plrWins: .equate 12  ;Aly return code: Game over, Player Wins
plrLose: .equate 6   ;Aly return code: Game over, Player Loses

BR BAmain
NOP0 ;memory spacer
NOP0 ;memory spacer
NOP0 ;memory spacer
NOP0 ;memory spacer
NOP0 ;memory spacer

;dynamic board
dynamic: .block 64 ;must match boardE // Dynamic board - one long line 'dynamic'
; Can replace with following to test alignment
;.ascii "c*123456" 
;.ascii "#####*87"
;.ascii "****#*##"
;.ascii "*##*#*#*"
;.ascii "*#**#*#*"
;.ascii "*#**#*#*"
;.ascii "*####*#*"
;.ascii "****6*6*"
dynplrSM: .equate "c" 
dynplrLG: .equate "C"
dyndead:  .equate "X" 
dynclear: .equate "."
dynsafe:  .equate "*"
dynpit:   .equate "#"
;1-8 mean "1-8 roudns until safe"
;* means "safe (at least for next move)"

;;static board
static: .block 64 ;must also match boardE // Static board - one long line 'static'
; Can replace with following for a 'default board'
;.ascii "S0123456" 
;.ascii "99999087"
;.ascii "00009099"
;.ascii "09909090"
;.ascii "09009090"
;.ascii "09009090"
;.ascii "09999090"
;.ascii "00006060"

stcstart: .equate "S" 
stcsafe:  .equate "0"
stcpit:   .equate "9" 
;0 means "always safe"
;9 means "always deadly"
;1-8 mean "1-8 rounds deadly, 1 round safe"


;Tracking variables
edible: .block 2 ;edible counter #2d (includes variable hazards)
lives: .block 2 ;lives counter #2d - when zero, player should be dead
playLoc: .block 2 ;location (offset in board array) of player #2d

;;;;****;;;;****;;;;****;;;;****;;;;****;;;;****

BAmain: NOP0
STRO BAwelcm,d
CALL JLshell,i
STRO BAgdbye,d
STOP
;;Strings for main
BAwelcm: .ascii "Welcome to the CS225 Poison/Lava game."
BAgdbye: .ascii "Thank you for playing the CS225 Poison/Lava game."

;;;;****;;;;****;;;;****;;;;****;;;;****;;;;****
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;SHELL
.ascii "--------JL SHELL--------"

;Jamie's menu shell and game loop
;No arguments
;No return values

JLchoice: .equate 0 ;local variable #2d
JLframe: .equate 2 ;size of Jamie's local variable frame
JLMENUS: .equate 4 ;constant for total number of menu items

JLshell: NOP0
SUBSP JLframe,i ;deallocate #JLchoice
JLgomenu: STRO JLmenu,d
DECI JLchoice,s
LDX JLchoice,s
CPX 1,i ;see if menu input was less than 1
BRLT JLdeflt ;if menu input < 1 branch to JLdeflt
CPX JLMENUS,i ;see if menu input was greater than 4
BRGT JLdeflt ;if menu input > 4 branch to JLdeflt
BR JLmnmain ;once input is vetted, branch to menu choices. code branches to the line right below it but this structure allows for future expansion
JLmnmain: NOP0
ASLX ;double size of user input in X to use as offset
BR JLloctns,x
JLdeflt: BR JLgomenu
JLone: CALL JLcurrnt
BR JLdonecs
JLtwo: CALL JLvwcurr
BR JLdonecs
JLthree: CALL JLnewbrd
BR JLdonecs
JLfour: BR JLshlbye
JLdonecs: BR JLgomenu
JLshlbye: ADDSP JLframe,i ;deallocate #JLchoice
RET0

;Jamie's strings and supporting subroutines
JLmenu: .ASCII "\n*********************************\n**       M A I N M E N U       **\n*********************************\n**                             **\n**   [1] Play Current Board    **\n**   [2] View Current Board    **\n**   [3] Enter New Board       **\n**   [4] Exit                  **\n**                             **\n*********************************\nTYPE YOUR SELECTION AND PRESS ENTER: \x00"
JLrules: .ASCII "Move your guy using A (left), D (right),\nW (up), and S (down). NOT case sensitive.\nIcon Key:\n* = nom (You can eat this!)\n. = empty (You already ate here!)\n# = lava pit (Go there, you die!)\ninteger = poison (after each move the\nnumber goes down by one, it's safe for one\nturn after it counts down from 1)\n\x00"
JLkey: .ASCII "\nIcon Key:\n0 = nom (You can eat this!)\nS = player starting location\n9 = lava pit (Go there, you die!)\ninteger = poison (after each move the\nnumber goes down by one, it's safe for one\nturn after it counts down from 1)\n\x00"
JLuwin: .ASCII "\n**************************\n**  G A M E  O V E R !  **\n**************************\n**                      **\n**       You WIN!       **\n**                      **\n**************************\nNumber of Round: \x00"
JLulose: .ASCII "\n**************************\n**  G A M E  O V E R !  **\n**************************\n**                      **\n**       You LOSE!      **\n**                      **\n**************************\n\x00"
JLcurr: .ASCII "\n*****************************\n**  View of Current Board  **\n*****************************\n\n\x00"
JLnwrule: .ASCII "\nEnter 64 total characters that will be\ntranslated into 8 rows of 8 characters.\nAll 'illegal' characters will be ignored\nso feel free to put line feeds into the\nbatch input.\nA '0' is an edible. A '9' is a permanent\nlava pit. A single integer from 1-8 counts\ndown one number per move. It's poison while\nit's a number, and it's edible for one turn\nafter it counts down from 1.An upper case\n'S' is the player's starting location.\n\x00"
JLloctns: .ADDRSS JLdeflt ;Jump table
.ADDRSS JLone
.ADDRSS JLtwo
.ADDRSS JLthree
.ADDRSS JLfour

JLcurrnt: NOP0 ;menu option 1 is chosen
JLround: .equate 0 ;local variable #2d
JLcrfram: .equate 2 ;frame size for JLcurrnt local variables
SUBSP JLcrfram,i ;allocate #JLround
LDA 0,i
STA JLround,s ;set round number to 0
CALL GMsetup ;initialize a new board
STRO JLrules,d
JLgoplay: NOP0 ;prepare to call JLplay
MOVSPA ;put address of SP into A
ADDSP JLround,i ;now A contains the memory address of JLround. adding 0 is unnecessary but it will make life easier if the program is expanded in the future
STA JLplarg,s ;argument for JLplay
SUBSP JLplpush,i ;push #JLplrtn #JLplpar
CALL JLplay
ADDSP JLplpush,i ;pop #JLplrtn #JLplpar
LDA JLplrslt,s ;at this point the game is over, load the win or lose result into A
CPA plrWins,i
BREQ JLplwin
CPA plrLose,i ;technically unnecessary because the only two results that should be stored here are win or lose
BREQ JLpllose ;I wonder if there should be an "emergency catch" branch after this line in case there was somehow a non-win/lose result
JLplwin: NOP0
STRO JLuwin,d
DECO JLround,s
BR JLcurdun
JLpllose: NOP0
STRO JLulose,d
JLcurdun: NOP0
ADDSP JLcrfram,i ;deallocate #JLround
RET0

JLplay: NOP0 ;vet input for moving the dude
JLplarg: .equate -4 ;location of address of round number from caller's perspective
JLplrslt: .equate -2 ;location of player win/lose status from caller's perspective
JLplpar: .equate 3 ;location of address of round number from callee's perspective - formal parameter #2h
JLplrtn: .equate 5 ;location of player win/lose status from callee's perspective - #2d
JLplpush: .equate 4 ;size of JLplay's arguments and return values
JLgtinpt: .equate 0 ;input for JLplay function - local variable #1c
JLplfram: .equate 1 ;local variable frame size for JLplay function
SUBSP JLplfram,i ;allocate #JLgtinpt
JLgetchr: CHARI JLgtinpt,s
LDA 0,i ;clear accumulator
LDBYTEA JLgtinpt,s
ORA 0x20,i
STBYTEA JLgtinpt,s
CPA 'w',i ;see if there's a w in A
BREQ JLgdinpt ;good input
CPA 'a',i ;see if there's an a in A
BREQ JLgdinpt ;good input
CPA 's',i ;see if there's an s in A
BREQ JLgdinpt ;good input
CPA 'd',i ;see if there's a d in A
BREQ JLgdinpt
BR JLgetchr ;if input is bad keep trying
JLgdinpt: NOP0 ;this is for good input
LDA JLplpar,sf ;load round counter into A
ADDA 1,i ;increment round counter by 1
STA JLplpar,sf ;store the incremented round counter
LDBYTEA JLgtinpt,s
STBYTEA NPplMove,s
SUBSP NPargz,i ;push #NPparam
CALL NPmove
ADDSP NPargz,i ;pop #NPparam
CALL CSupdate ;after player moves, update the board
SUBSP AMjudge,i ;push #AMresult 
CALL AMisOver ;check to see if the game is over
ADDSP AMjudge,i ;pop #AMresult 
LDA AMgmStat,s ;load result of game-over check into A
CPA gameNovr,i
BREQ JLgetchr ;game isn't over so go get more user input
LDA AMgmStat,s
STA JLplrtn,s ;return value of function (win/lose status)
ADDSP JLplfram,i ;deallocate #JLgtinpt
RET0

JLvwcurr: NOP0 ;menu selection 2: view current board
JLvwcnt1: .equate 0 ;local variable #2d
JLvwcnt2: .equate 2 ;local variable #2d
JLvwfram: .equate 4 ;frame size for JLvwcurr's local variable(s)
SUBSP JLvwfram,i ;allocate #JLvwcnt2 #JLvwcnt1
LDX 0,i
STX JLvwcnt1,s ;zero the counter
STX JLvwcnt2,s ;zero the counter
STRO JLcurr,d ;header text
BR JLvwloop
JLlnfeed: CHARO "\n",i
LDX 0,i
STX JLvwcnt2,s
JLvwloop: NOP0 ;loops boardE times individually outputting charcters in the static board inserting a linefeed every boardWth character
LDX JLvwcnt1,s
CHARO static,x
ADDX 1,i
CPX boardE,i
BRGE JLvwbye
STX JLvwcnt1,s
LDX JLvwcnt2,s
ADDX 1,i
CPX boardW,i
BRGE JLlnfeed ;after every boardWth character a linefeed is inserted
STX JLvwcnt2,s
BR JLvwloop
JLvwbye: NOP0
STRO JLkey,d
ADDSP JLvwfram,i ;deallocate #JLvwcnt1 #JLvwcnt2
RET0

JLnewbrd: NOP0
JLnwcntr: .equate 0 ;local variable #2d
JLnwhold: .equate 2 ;local variable #2d
JLnwfram: .equate 4 ;frame size for JLnewbrd's local variable(s)
SUBSP JLnwfram,i ;allocate #JLnwhold #JLnwcntr
LDX 0,i
LDA 0,i ;accumulator must be cleared for purposes of testing individual characters
STX JLnwcntr,s ;zero the counter
STRO JLnwrule,d ;output the instructions
JLnwget: CHARI JLnwhold,s
LDBYTEA JLnwhold,s ;loads the inputted character into the accumulator
CPA 'S',i ;check if the inputted character is S
BREQ JLnwgood ;the input is good so keep it
CPA '0',i
BRLT JLnwget ;the input is not an S but is less than zero so it's no good, ignore it
CPA '9',i
BRGT JLnwget ;the input is not an S and is greater than 0 but it's also greater than 9 so it's no good, ignore it
JLnwgood: STBYTEA static,x ;this line is branched to if input is S. if input is not S but is >=0 and <=9 the program will just "fall through" to this line
ADDX 1,i
CPX boardE,i ;loops stops running after inputting the boardEth character
BRLT JLnwget 
ADDSP JLnwfram,i ;deallocate #JLnwcntr #JLnwhold
RET0

;;;;****;;;;****;;;;****;;;;****;;;;****;;;;****

;Aly's Game Over function
;No arguments
;One return value
AMgmStat: .equate -2 ;fill in as appropriate return value name  (for use by caller)
AMresult: .equate 2 ;fill in as appropriate parameter (for use by AMisOver)
AMjudge: .equate 2 ;size to push/pop (for use by caller)

AMisOver: NOP0
;use lives and edible count to check for game over.
;if lives < 0, game over and player lose
;else if edible ==/< 0, game over and player win
;else game not over
 
RET0
;Aly's strings and supporting subroutines

;;;;****;;;;****;;;;****;;;;****;;;;****;;;;****

;Neale's move player function
;One lower-case wasd (char) argument
;No return value
;Caution: No compare byte instruction - clear upper byte for character testing

NPplMove: .equate 999 ;fill in argument (caller's view)
NPparam: .equate 999 ;fill in parameter (NPmove's view)
NPargz: .equate 999 ;fill in size to push/pop (for use by caller)
NPmove: NOP0
RET0
;Neale's strings and supporting subroutines

;;;;****;;;;****;;;;****;;;;****;;;;****;;;;****

;Caitlin's board update function
;No arguments
;No return values
CSupdate: NOP0 
RET0
;Caitlins's strings and supporting subroutines

;;;;****;;;;****;;;;****;;;;****;;;;****;;;;****

;Gillian's setup board function
;No arguments
;No return values
GMsetup: NOP0
RET0
;Gillian's strings and supporting subroutines

;;;;****;;;;****;;;;****;;;;****;;;;****;;;;****
.end