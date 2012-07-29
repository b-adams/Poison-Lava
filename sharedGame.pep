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