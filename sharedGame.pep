;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;Constants
boardL: .equate 8  ;board length
boardW: .equate 8  ;board width
boardE: .equate 64 ;number of elements

gameNovr: .equate 42 ;Aly return code: Game not over
plrWins: .equate 12  ;Aly return code: Game over, Player Wins
plrLose: .equate 6   ;Aly return code: Game over, Player Loses

MOVup: .equate "w"
MOVleft: .equate "a"
MOVdown: .equate "s"
MOVright: .equate "d"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;Jump to program and alignment bytes
BR BAmain
.ascii "     " ;memory spacer

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;Dynamic Board
.ascii "        V board "
dynamic: .block 64 ;must match boardE // Dynamic board - one long line 'dynamic' #1c64a

; Can replace with following to test alignment
;.ascii "c*123456"
;.ascii "#####987"
;.ascii "****#*##"
;.ascii "*##*#*#*"
;.ascii "*#**#*#*"
;.ascii "*#**#*#*"
;.ascii "*####*#*"
;.ascii "****6*6*"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;Dynamic Board Visuals
dynplrSM: .equate "c"
dynplrLG: .equate "C"
dyndead:  .equate "X"
dynclear: .equate " "
dynsafe:  .equate "."
dynpit:   .equate "#"
;1-8 mean "1-8 rounds until safe"
;* means "safe (at least for next move)"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;Static Board
.ascii "        V  map  "
;static: .block 64 ;must also match boardE // Static board - one long line 'static' #1c64a
; Can replace with following for a 'default board'
static: .ascii "90123456"
.ascii "99999087"
.ascii "00009099"
.ascii "09909090"
.ascii "09009090"
.ascii "09009090"
.ascii "09999090"
.ascii "0000606S"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;Static Board Visuals
stcstart: .equate "S"
stcsafe:  .equate "0"
stcpit: .equate "9"
;0 means "always safe"
;9 means "always deadly"
;1-8 mean "1-8 rounds deadly, 1 round safe"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;Global Variables
.ascii "        V  data "
edibles: .block 2 ;edible counter #2d (includes variable hazards)
lives: .block 2 ;lives counter #2d - when zero, player should be dead
playLoc: .block 2 ;location (offset in board array) of player #2d

.ascii "  " ;BA Alignment
.ascii "        " ;BA Spacer

;;;;****;;;;****;;;;****;;;;****;;;;****;;;;****
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;MAIN
.ascii "--------BA  MAIN--------"

BAmain: NOP0
STRO BAwelcm,d
CALL JLshell,i
STRO BAgdbye,d
STOP

.ascii "     " ;BA Alignment
.ascii "        " ;BA Spacer

;;;;****;;;;****;;;;****;;;;****;;;;****;;;;****
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;ISOVER
.ascii "--------AMISOVER--------"

;Aly's Game Over function
;AMisOver():gameOverInt
;One return value (gameNovr, plrWins, or plrLose)

AMgmStat: .equate -2 ;fill in as appropriate return value name  (for use by caller)
AMresult: .equate 2 ;local variable #2d
AMjudge: .equate 2 ;size to push/pop (for use by caller)

AMisOver: NOP0
;use lives and edible count to check for game over.
;if lives <= 0, game over and player lose
;else if edible > 0, game over and player win
;else game not over
lda lives,d
brle LosRes ;checking if lives <= 0...
lda edibles,d
brle WinRes ;checking if edible count <= 0...
br AllElse ;neither skipped, so game not over yet
LosRes: nop0 ;load player loss result and store it in AMresult, return
lda plrLose,i
sta AMresult,s
br Done
WinRes: nop0 ;load player win result and store it in AMresult, return
lda plrWins,i
sta AMresult,s
br Done
AllElse: nop0 ;load game not over result and store it in AMresult, return
lda gameNovr,i
sta AMresult,s
Done: RET0

.ascii "    " ;BA Alignment
.ascii "        " ;BA Spacer

;;;;****;;;;****;;;;****;;;;****;;;;****;;;;****
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;UPDATE
.ascii "--------CSUPDATE--------"

;Caitlin's board update function
;CSupdate():void

CSupdate: NOP0
;If there were local variables, allocate them here

;for (i=0; i<64; i ++)
LDX 0,i;getting ready to zero out running total
;
CSstart: NOP0 ;start of comparison loop
LDA 0,i ;clear accumulator
LDBYTEA dynamic,x;
CPA dynpit,i ;if(accumulator==dynpit) 
BREQ updateX,i ;do nothing, pits stay pits
CPA dynclear,i ;else if(accumulator==dynclear) 
BREQ updateX,i ;do nothing, eaten spots stay eaten
CPA dynplrSM,i ;else if(accumulator==dynplrSM) {
BREQ updateX,i ;do nothing, changing the player is Neale's job
CPA dynplrLG,i ;else if(accumulator==dynplrLG) {
BREQ updateX,i ;do nothing, changing the player is Neale's job
CPA dyndead,i ;else if(accumulator==dyndead) {
BREQ updateX,i ;do nothing, dead players don't decompose
CPA dynsafe,i ;else if(accumulator==dynsafe) {
BREQ CSdoStar,i ;if there is a star 
SUBA 1,i ; accumulator--
CPA stcsafe,i ; if(accumulator==stcsafe){ 
BREQ putstar,i  ;We decremented from a 1 to a 0, so need a * on the board accumulator=dynsafe
STBYTEA dynamic,x; } else { 
BR updateX,i ;//we decremented something that didn't become a 0, so that will be used
;
;***************************************
CSdoStar: NOP0 ; else if(accumulator==dynsafe) {
LDA 0,i ;clear accumulator 
LDBYTEA static,x ;//Need to know if this is an always-* or a sometimes-* accumulator=static[runtot]
CPA stcsafe,i ; comparing the static[x] to stcsafe
BREQ updateX,i ;if(accumulator==stcsafe)    //do nothing, 0 on the static board is always * on dynamic
STBYTEA dynamic,x;} else {reset the * on dynamic board to the static number, dynamic[runtot] = accumulator
BR updateX,i
;***************************************
;
;***************************************
putstar: NOP0
LDBYTEA dynsafe,i
STBYTEA dynamic,x; Put the updated symbol on the board
BR updateX,i; go to increment the counter
;***************************************
;
;***************************************
updateX: NOP0
ADDX 1,i ; i ++
CPX boardE,i
BRLT CSstart,i ;if i < 64 restart loop with incremented index register
;***************************************
;
end: NOP0 ;Deallocate local variables... oh wait, there aren't any!
RET0
;***************************************
;


.ascii " " ;BA Alignment
.ascii "        " ;BA Spacer

;;;;****;;;;****;;;;****;;;;****;;;;****;;;;****
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;SETUP
.ascii "--------GM SETUP--------"

;Gillian's setup board function
;GMsetup():void

GMsetup: NOP0

;set player's lives
lda 1,i
sta lives,d

;initialize edibles to 0
lda 0,i
sta edibles,d ;ERROR: Symbol edibles is used but not defined.

;set up the board
ldx 0,i

;loop starts here
FOR: NOP0
cpx boardE,i
brge endfor

;start checking characters in the static board
;if (char == "0")
ldbytea static,x
cpa stcsafe,i
breq edblespc
;elseif (char == "9")
cpa stcpit,i
breq lava
;elseif (char == "S")
cpa stcstart,i
breq player
;else
br chngedbl

;continuation of the loop
forcont: NOP0
addx 1,i
br FOR

endfor: NOP0
RET0

;Gillian's supporting subroutines

;edible case
edblespc: NOP0
ldbytea dynsafe,i
stbytea dynamic,x
lda edibles,d
adda 1,i
sta edibles,d
br forcont

;shifting edible case
chngedbl:NOP0
stbytea dynamic,x
lda edibles,d
adda 1,i
sta edibles,d
br forcont

;Poison lava case
lava:NOP0
ldbytea dynpit,i
stbytea dynamic,x
br forcont

;player start case
player:NOP0
ldbytea dynplrLG,i
stbytea dynamic,x
;store the player's location (using the loop counter as the location)
stx playLoc,d
br forcont

.ascii "      " ;BA Alignment
.ascii "        " ;BA Spacer

;;;;****;;;;****;;;;****;;;;****;;;;****;;;;****
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;MOVE
.ascii "--------NP  MOVE--------"

;Neale's move player function
;NPmove(movedirWASD:char):void
;One lower-case wasd (char) argument

NPconvrt: .equate 0 ;local variable #2d
NPsize: .equate 2
NPparam: .equate 4 ;formal parameter #1c
NPplMove: .equate -1 ;callers view of argument
NPargz: .equate 1 ;size to push/pop


NPmove: NOP0
SUBSP NPsize,i ;allocate #NPconvrt 
;---------------------------------------------------------------- Modify the player location based on the input
;Case w
LDA 0,i
LDBYTEA NPparam,s
CPA MOVup,i
BRNE NPnotW
LDA playLoc,d
SUBA boardW,i
STA NPconvrt,s
BR NPovrFlo

;Case a
NPnotW: NOP0
LDA 0,i
LDBYTEA NPparam,s
CPA MOVleft,i
BRNE NPnotWA
LDA playLoc,d
SUBA 1,i
STA NPconvrt,s
BR NPovrFlo

;Case s
NPnotWA: NOP0
LDA 0,i
LDBYTEA NPparam,s
CPA MOVdown,i
BRNE NPnotWAS
LDA playLoc,d
ADDA boardW,i
STA NPconvrt,s
BR NPovrFlo

;Case d
NPnotWAS: NOP0
LDA playLoc,d
ADDA 1,i
STA NPconvrt,s

;---------------------------------------------------------------- Check to see if it's out of bounds
NPovrFlo:NOP0
;check to see if it's less than 0 or greater than boardE

LDA NPconvrt,s
BRLT NPtop ;target < 0 indicates top overflow

CPA boardE,i
BRGE NPbottom ;target >= 64 indicates bottom overflow
BR NPsymChg

NPtop: NOP0
LDA NPconvrt,s
ADDA boardE,i ;add 64 to get back onto board
STA NPconvrt,s
BR NPsymChg

NPbottom: NOP0
LDA NPconvrt,s
SUBA boardE,i ;subtract 64 to get back onto board
STA NPconvrt,s

;---------------------------------------------------------------- Change the new location's thingy
NPsymChg: NOP0

LDX NPconvrt,s
LDA 0,i
LDBYTEA dynamic,x

;if the new location is already eaten just move
CPA dynclear,i
BREQ NPisSafe
;if the new location is neither clear nor edible
CPA dynsafe,i
BRNE NPnoSafe
;since the new location is edible, eat it then move
;subtract edible counter
LDA edibles,d
SUBA 1,i
STA edibles,d

;if the character is a c make it a C and so on
NPisSafe:NOP0
LDX playLoc,d
LDA 0,i
LDBYTEA dynamic,x
CPA dynplrSM,i
BRNE NPbigC ;if player is not small, they must be a big C

NPsmlC: LDA 0,i ;in this case, they must be a small C
LDX NPconvrt,s
LDBYTEA dynplrLG,i
STBYTEA dynamic,x
BR NPover

NPbigC:NOP0
LDX NPconvrt,s
LDBYTEA dynplrSM,i
STBYTEA dynamic,x
BR NPover

;if the new location isn't safe kill the player
NPnoSafe: NOP0
LDX NPconvrt,s
LDBYTEA dyndead,i
STBYTEA dynamic,x
LDA lives,d
SUBA 1,i
STA lives,d

NPover: NOP0
;put clear marker where player was
LDX playLoc,d
LDBYTEA dynclear,i
STBYTEA dynamic,x
;save the new location
LDA NPconvrt,s
STA playLoc,d

ADDSP NPsize,i ;DEallocate #NPconvrt 
RET0 

.ascii "       " ;BA Alignment
.ascii "        " ;BA Spacer

;;;;****;;;;****;;;;****;;;;****;;;;****;;;;****
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;SHELL
.ascii "--------JL SHELL--------"

;Jamie's menu shell and game loop
;JLshell():void

JLchoice: .equate 0 ;local variable #2d
JLframe: .equate 2 ;size of Jamie's local variable frame
JLMENUS: .equate 4 ;constant for total number of menu items

JLshell: NOP0
SUBSP JLframe,i ;deallocate #JLchoice
JLgomenu: STRO JLmenu,d
DECI JLchoice,s
LDX JLchoice,s
BRLE JLdeflt ;if menu input <=0 branch to JLdeflt
CPX JLMENUS,i ;see if menu input was greater than 4
BRGT JLdeflt ;if menu input > 4 branch to JLdeflt
BR JLmnmain ;once input is vetted, branch to menu choices. code branches to the line right below it but this structure allows for future expansion

JLmnmain: NOP0
ASLX ;double size of user input in X to use as offset
BR JLloctns,x

JLdeflt: BR JLgomenu
JLone: CALL JLcurrnt
BR JLendCas
JLtwo: CALL JLvwcurr
BR JLendCas
JLthree: CALL JLnewbrd
BR JLendCas
JLfour: BR JLshlbye
JLendCas: BR JLgomenu

JLshlbye: ADDSP JLframe,i ;deallocate #JLchoice
RET0

;Jump table for switch
JLloctns: .ADDRSS JLdeflt ;Jump table
.ADDRSS JLone
.ADDRSS JLtwo
.ADDRSS JLthree
.ADDRSS JLfour

;Jamie's supporting functions and subroutines

;;*****************************
;;JLcurrnt():void - play current board
JLround: .equate 0 ;local variable #2d
JLcrfram: .equate 2 ;frame size for JLcurrnt local variables

JLcurrnt: NOP0 ;menu option 1 is chosen
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

;;*****************************
;;JLplay(roundNum:int*):int - play loop (get input, move player, update board, check game over)
;;First argument is address of variable holding round number
;;Returns win/loss code
JLplarg: .equate -4 ;location of address of round number from caller's perspective
JLplrslt: .equate -2 ;location of player win/lose status from caller's perspective
JLplpar: .equate 3 ;location of address of round number from callee's perspective - formal parameter #2h
JLplrtn: .equate 5 ;location of player win/lose status from callee's perspective - #2d
JLplpush: .equate 4 ;size of JLplay's arguments and return values
JLgtinpt: .equate 0 ;input for JLplay function - local variable #1c
JLplfram: .equate 1 ;local variable frame size for JLplay function

JLplay: NOP0 ;vet input for moving the dude
SUBSP JLplfram,i ;allocate #JLgtinpt

JLgetchr: nop0
CHARI JLgtinpt,s

LDA 0,i ;clear accumulator
LDBYTEA JLgtinpt,s
ORA 0x20,i ;force letters to lower case
STBYTEA JLgtinpt,s
CPA MOVup,i ;see if there's a w in A
BREQ JLgdinpt ;good input
CPA MOVleft,i ;see if there's an a in A
BREQ JLgdinpt ;good input
CPA MOVdown,i ;see if there's an s in A
BREQ JLgdinpt ;good input
CPA MOVright,i ;see if there's a d in A
BREQ JLgdinpt
BR JLgetchr ;if input is bad keep trying

JLgdinpt: NOP0 ;this is for good input
;Update round counter
LDA JLplpar,sf ;load round counter into A
ADDA 1,i ;increment round counter by 1
STA JLplpar,sf ;store the incremented round counter
;Move player
LDBYTEA JLgtinpt,s
STBYTEA NPplMove,s
SUBSP NPargz,i ;push #NPparam
CALL NPmove 
ADDSP NPargz,i ;pop #NPparam
;Update board
CALL CSupdate ;after player moves, update the board
;Check gameover
SUBSP AMjudge,i ;push #AMresult 
CALL AMisOver ;check to see if the game is over
ADDSP AMjudge,i ;pop #AMresult 
;Indicate work has been done
deco JLplpar,sf ;BA Addition for user to see number of round
charo ':',i ;BA Addition for user to see number of round
;Decide whether to loop or to return
LDA AMgmStat,s ;load result of game-over check into A
CPA gameNovr,i
BREQ JLgetchr ;game isn't over so go get more user input
LDA AMgmStat,s
STA JLplrtn,s ;return value of function (win/lose status)
ADDSP JLplfram,i ;deallocate #JLgtinpt
RET0

;;*****************************
;;JLvwcurr():void - view current board
JLvwcnt1: .equate 0 ;local variable #2d
JLvwcnt2: .equate 2 ;local variable #2d
JLvwfram: .equate 4 ;frame size for JLvwcurr's local variable(s)

JLvwcurr: NOP0 ;menu selection 2: view current board
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

;;*****************************
;;JLnewbrd():void - user enters new board
JLnwcntr: .equate 0 ;local variable #2d
JLnwhold: .equate 2 ;local variable #2d
JLnwfram: .equate 4 ;frame size for JLnewbrd's local variable(s)

JLnewbrd: NOP0
SUBSP JLnwfram,i ;allocate #JLnwhold #JLnwcntr
LDX 0,i
STX JLnwcntr,s ;zero the counter
STRO JLnwrule,d ;output the instructions

LDA 0,i ;accumulator must be cleared for purposes of testing individual characters

JLnwget: CHARI JLnwhold,s
LDBYTEA JLnwhold,s ;loads the inputted character into the accumulator
CPA stcstart,i ;check if the inputted character is S
BREQ JLnwgood ;the input is good so keep it
CPA stcsafe,i
BRLT JLnwget ;the input is not an S but is less than zero so it's no good, ignore it
CPA stcpit,i
BRGT JLnwget ;the input is not an S and is greater than 0 but it's also greater than 9 so it's no good, ignore it

JLnwgood: STBYTEA static,x ;this line is branched to if input is S. if input is not S but is >=0 and <=9 the program will just "fall through" to this line
ADDX 1,i
CPX boardE,i ;loops stops running after inputting the boardEth character
BRLT JLnwget

ADDSP JLnwfram,i ;deallocate #JLnwcntr #JLnwhold
RET0


.ascii "" ;BA Alignment
.ascii "        " ;BA Spacer

;;;;****;;;;****;;;;****;;;;****;;;;****;;;;****
;;STRINGS
.ascii "--------STR INGS--------"

;;Strings for BA main
BAwelcm: .ascii "Welcome to the CS225 Poison/Lava game.\x00"
BAgdbye: .ascii "Thank you for playing the CS225 Poison/Lava game.\x00"

;Jamie's strings and supporting subroutines
JLmenu: .ASCII "\n*********************************\n**       M A I N M E N U       **\n*********************************\n**                             **\n**   [1] Play Current Board    **\n**   [2] View Current Board    **\n**   [3] Enter New Board       **\n**   [4] Exit                  **\n**                             **\n*********************************\nTYPE YOUR SELECTION AND PRESS ENTER: \x00"
JLrules: .ASCII "Move your guy using A (left), D (right),\nW (up), and S (down). NOT case sensitive.\nIcon Key:\n* = nom (You can eat this!)\n. = empty (You already ate here!)\n# = lava pit (Go there, you die!)\ninteger = poison (after each move the\nnumber goes down by one, it's safe for one\nturn after it counts down from 1)\n\x00"
JLkey: .ASCII "\nIcon Key:\n0 = nom (You can eat this!)\nS = player starting location\n9 = lava pit (Go there, you die!)\ninteger = poison (after each move the\nnumber goes down by one, it's safe for one\nturn after it counts down from 1)\n\x00"
JLuwin: .ASCII "\n**************************\n**  G A M E  O V E R !  **\n**************************\n**                      **\n**       You WIN!       **\n**                      **\n**************************\nNumber of Round: \x00"
JLulose: .ASCII "\n**************************\n**  G A M E  O V E R !  **\n**************************\n**                      **\n**       You LOSE!      **\n**                      **\n**************************\n\x00"
JLcurr: .ASCII "\n*****************************\n**  View of Current Board  **\n*****************************\n\n\x00"
JLnwrule: .ASCII "\nEnter 64 total characters that will be\ntranslated into 8 rows of 8 characters.\nAll 'illegal' characters will be ignored\nso feel free to put line feeds into the\nbatch input.\nA '0' is an edible. A '9' is a permanent\nlava pit. A single integer from 1-8 counts\ndown one number per move. It's poison while\nit's a number, and it's edible for one turn\nafter it counts down from 1.An upper case\n'S' is the player's starting location.\n\x00"

.ascii " " ;BA Alignment
.ascii "        " ;BA Spacer
.ascii "--------END PROG--------"

.end
