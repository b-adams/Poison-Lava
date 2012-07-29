# Update board elements #

You'll have access to the dynamic board and the static board

* If you see a number, decrement it
* If you see a 1, turn it to a *
* If you see a * on the dynamic board AND a number on the static board, update to that number
* If you see a * on dynamic and zero on static, do nothing
* . becomes .
* c becomes C
* C becomes c (initially, just do c -> c)
* x becomes X AND update the deadPlayer bit
* # becomes #