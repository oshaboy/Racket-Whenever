# Racket Whenever

A Racket language where the code executes semi-randomly. However a few commands are added to restrain it.


`defer`: Wait for a list of conditions to be met and lines to be executed before this line is executed.  
`clone!`: Take a line number and a count and copy the line "count" times.  
`N`: Takes a line number and returns how many of it exist.   
`again`: If a condition list is met, do not remove the line.   

Inspired by https://www.dangermouse.net/esoteric/whenever.html
