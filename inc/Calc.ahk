/*
Simple script for evaluating arithmetic expressions
by Laszlo
source: http://www.autohotkey.com/community/viewtopic.php?t=5060
*/
Eval(x)                                ; pre-process
{
   StringReplace x, x, %A_Space%,, All
   StringReplace x, x, %A_Tab%,, All   ; remove white space
   StringReplace x, x, pi, 3.141592653589793, All
   StringReplace x, x, e,  2.718281828459045, All
   StringReplace x, x, **, @, All      ; ** -> @ for easier process
   Return Eval@(x)
}

Eval@(x)
{
   If (Asc(x) = Asc("-"))
      Return Eval@("0" x)              ; -x -> 0 - x
   If (Asc(x) = Asc("+"))
      Return Right(x,0)                ; +x -> x
   StringGetPos i, x, +, R             ; i = -1 if no + is found
   StringGetPos j, x, -, R
   If (i > j)
      Return Left(x,i)+Right(x,i)
   If (j > i)                          ; i = j only if no + or - found
      Return Left(x,j)-Right(x,j)
   StringGetPos i, x, *, R
   StringGetPos j, x, /, R
   StringGetPos k, x,`%, R
   If (i > j && i > k)
      Return Left(x,i)*Right(x,i)
   If (j > i && j > k)
      Return Left(x,j)/Right(x,j)
   If (k > i && k > j)
      Return Mod(Left(x,k),Right(x,k))
   StringGetPos i, x, @, R
   If (i >= 0)
      Return Left(x,i)**Right(x,i)
   Return x
}

Left(x,i)
{
   StringLeft x, x, i
   Return Eval@(x)
}
Right(x,i)
{
   StringTrimLeft x, x, i+1
   Return Eval@(x)
}