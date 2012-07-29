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
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;MOVE
.ascii "--------NP  MOVE--------"

;Neale's move player function
;One lower-case wasd (char) argument
;No return value
NPconvrt: .equate 2 ;local variable #2d
NPmax: .equate 0 ;local variable #2d
NPsize: .equate 4
NPparam: .equate 6 ;formal parameter #1c
NPplMove: .equate -1 ;callers view of argument
NPargz: .equate 1 ;size to push/pop

NPmove: NOP0
SUBSP NPsize,i ;allocate #NPconvrt #NPmax 
;---------------------------------------------------------------- Modify the player location based on the input
;Case w
LDA 0,i
LDBYTEA NPparam,s
CPA 'w',i
BRNE NPnotW
LDA playLoc,d
SUBA boardW,i
STA NPconvrt,s
BR NPover

;Case a
NPnotW: NOP0
LDA 0,i
LDBYTEA NPparam,s
CPA 'a',i
BRNE NPnotA
LDA playLoc,d
SUBA 1,i
STA NPconvrt,s
BR NPover

;Case s
NPnotA: NOP0
LDA 0,i
LDBYTEA NPparam,s
CPA 's',i
BRNE NPnotS
LDA playLoc,d
ADDA boardW,i
STA NPconvrt,s
BR NPover

;Case d
NPnotS: NOP0
LDA 0,i
LDA playLoc,d
ADDA 1,i
STA NPconvrt,s

;---------------------------------------------------------------- Check to see if it's out of bounds
NPover:NOP0
;check to see if it's less than 0 or greater than boardE
LDA boardE,i
SUBA 1,i
STA NPmax,s

LDA NPconvrt,s
BRLT NPtop

CPA NPmax,s
BRGT NPbottom
BR NPover2

NPtop: NOP0
LDA NPconvrt,s
ADDA boardE,i
STA NPconvrt,s
BR NPover2

NPbottom: NOP0
LDA NPconvrt,s
SUBA boardE,i
STA NPconvrt,s

;---------------------------------------------------------------- Change the new location's thingy
NPover2: NOP0

;if the new location is all ready eaten just move
LDA 0,i
LDX NPconvrt,s
LDBYTEA dynamic,x
CPA dynclear,i
BREQ NPisSafe

;if the new location is ediable, eat it then move
LDA 0,i
LDBYTEA dynamic,x
CPA dynsafe,i
BRNE NPnoSafe
;subtract edible counter
LDA edible,d
SUBA 1,i
STA edible,d

;if the character is a c make it a C and so on
NPisSafe:NOP0
LDA 0,i
LDX playLoc,d
LDBYTEA dynamic,x
CPA dynplrSM,i
BRNE NPbigC
LDA 0,i
LDX NPconvrt,s
LDBYTEA dynplrLG,i
STBYTEA dynamic,x
BR NPover3

NPbigC:NOP0
LDA 0,i
LDX NPconvrt,s
LDBYTEA dynplrSM,i
STBYTEA dynamic,x
BR NPover3

;if the new location isn't safe kill the player
NPnoSafe: NOP0
LDA 0,i
LDX NPconvrt,s
LDBYTEA dyndead,i
STBYTEA dynamic,x
LDA lives,d
SUBA 1,i
STA lives,d

;save the new location
NPover3: NOP0
LDX playLoc,d
LDA 0,i
LDBYTEA dynclear,i
STBYTEA dynamic,x

LDA NPconvrt,s
STA playLoc,d

ADDSP NPsize,i ;DEallocate #NPmax #NPconvrt 
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