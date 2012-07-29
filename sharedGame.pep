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

;Jamie's menu shell and game loop
;No arguments
;No return values
;Caution: No compare byte instruction - clear upper byte for character testing
JLshell: NOP0
RET0
;Jamie's strings and supporting subroutines

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
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;UPDATE
.ascii "--------CSUPDATE--------"

;Caitlin's board update function
;No arguments
;No return values
CSupdate: NOP0

runtot: .equate 0;local variable #2d 
;create a runtime variable to denote which element of the dynamic board on 
CSframe:.equate 2;framesize for local variables for CSupdate
;for (i=0; i<64; i ++)
LDA 0,i;getting ready to zero out running total
STA runtot,s;runtot = 0
;
SUBSP CSframe,i
CALL start
ADDSP CSframe,i
RET0
;
start: NOP0 ;start of comparison loop
LDA 0,i;zero out accumulator
LDX runtot,s;loads running total to x index

LDBYTEA dynamic,x;

CPA '*',i ;if(accumulator==dynpit) 
BREQ always,i ;do nothing, pits stay pits
CPA '.',i ;else if(accumulator==dynclear) 
BREQ doNoth,i ;do nothing, eaten spots stay eaten
CPA 'c',i ;else if(accumulator==dynplrSM) {
BREQ doNoth,i ;do nothing, changing the player is Neale's job
CPA 'C',i ;else if(accumulator==dynplrLG) {
BREQ doNoth,i ;do nothing, changing the player is Neale's job
CPA 'X',i ;else if(accumulator==dyndead) {
BREQ doNoth,i ;do nothing, dead players don't decompose
;*************************
always: NOP0 ; else if(accumulator==dynsafe) {
LDA static,x;//Need to know if this is an always-* or a sometimes-* accumulator=static[runtot]
CPA 0,i
BREQ doNoth,i ;if(accumulator==stcsafe)    //do nothing, 0 on the static board is always * on dynamic
STBYTEA dynamic,x;} else {reset the * on dynamic board to the static number, dynamic[runtot] = accumulator
RET0  
;***************************************
LDBYTEA dynamic,x;the only option left is there's a number to decrement
SUBA 1,i; accumulator--
CPA 0,i; if(accumulator==stcsafe){ 
BREQ putstar,i  ;We decremented from a 1 to a 0, so need a * on the board accumulator=dynsafe
STBYTEA dyanamic,x; } else {
BR doNoth,i ;//we decremented something that didn't become a 0, so that will be used
;
putstar: NOP0
LDBYTEA '*',i
STBYTEA dynamic,x;Put the updated symbol on the board
doNoth: NOP0
LDA runtot,s;
;
CPA 64,i
BREQ end,i
ADDA 1,i; running total ++
STA runtot,s
BR start,i
;
end: NOP0
RET0
;

;;;;****;;;;****;;;;****;;;;****;;;;****;;;;****

;Gillian's setup board function
;No arguments
;No return values
GMsetup: NOP0
RET0
;Gillian's strings and supporting subroutines

;;;;****;;;;****;;;;****;;;;****;;;;****;;;;****
.end