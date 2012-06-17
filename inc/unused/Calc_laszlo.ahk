/*
Popup calculator / expression evaluator (version 3.1 - Mon Jan 28, 2008 03:05)
By Laszlo
Source: http://www.autohotkey.com/community/viewtopic.php?t=26435
*/
Calculator Shortcuts:
   Esc:    Clear expression
   Home/End/BS/Del... Edit expression
   Up/Dn:  Next entry in history, which starts with current exp
   PgUp/PgDn: Move in exp history
   Ctrl-Home/End: 1st/Last history entry
   Alt-V/Enter: eValuate expression
   Alt-H/F1: Help
   Alt-E:    Edit history Start/Stop
   Alt-S:    Save history
   Alt-L:    Load history
   Ctrl-F1:  Find function under cursor highlighted in Help

Array Lists:
   Delayed double click: edit value
   Context menu: More, Less, refresh
   Enter, Alt-M: Moore (add new entry, Enter accepts)
   Alt-L: Less (delete last etry)
   Alt-R: Refresh (take over array changes)

Graph:
   Mouse cursor: crosshair with ToolTip (x,y)
   Right-click: MsgBox with current (x,y), ClipBoard copy: Ctrl-C

Basic constructs:
   ; : separator between expressions
   '..', "..", `word : quoated strings
   :=, +=, -=, *=, /=, //=, .=, |=, &=, ^=, >>=, <<= : assignments
   +, -, /, //, *, ** : arithemtic operators
   ~, &, |, ^, <<, >> : bitwise operators (shift is 64-bit signed)
   !, &&, || : logical operators
   . : string concatenation
   "c ? a : b" : ternary operator
   <, >, =, ==, <=, >=, <> (or !=) : relational operators
   ++, -- : pre- and post-increments

AHK Built-in variables:
    A_WorkingDir, A_ScriptDir, A_ScriptName, A_ScriptFullPath
    A_AhkVersion, A_AhkPath,
    A_YYYY, A_MM, A_DD, A_MMMM, A_MMM, A_DDDD, A_DDD, A_WDay, A_YDay
    A_YWeek, A_Hour, A_Min, A_Sec, A_MSec, A_Now, A_NowUTC, A_TickCount

    ComSpec, A_Temp, A_OSType, A_OSVersion, A_Language, A_ComputerName
    A_UserName, A_WinDir, A_ProgramFiles, A_AppData, A_AppDataCommon
    A_Desktop, A_DesktopCommon, A_StartMenu, A_StartMenuCommon
    A_Programs, A_ProgramsCommon, A_Startup, A_StartupCommon
    A_MyDocuments, A_IsAdmin, A_ScreenWidth, A_ScreenHeight, A_IPAddress1..4

AHK functions:
   InStr(Haystack, Needle [, CaseSensitive = false, StartingPos = 1])
   SubStr(String, StartingPos [, Length])
   StrLen(String)
   RegExMatch(Haystack, NeedleRegEx [, OutputVar = "", StartingPos = 1])
   RegExReplace(Hstck,Ndle[,Rpmnt="",OutVarCnt="",Limit=-1,StartPos=1])

   FileExist(FilePattern)
   WinExist([WinTitle, WinText, ExcludeTitle, ExcludeText])
   DllCall()

   NumGet(VarOrAddress [, Offset = 0, Type = "UInt"])
   NumPut(Number, VarOrAddress [, Offset = 0, Type = "UInt"])
   VarSetCapacity(UnquotedVarName [, RequestedCapacity, FillByte])

   Asc(String), Chr(Number)
   Abs(), Ceil(), Exp(), Floor(), Log(), Ln(), Mod(x,m), Round(x[,N]), Sqrt()
   Sin(), Cos(), Tan(), ASin(), ACos(), ATan()

General Functions:
   b("bits") : string of bits to number, Sign = MS_bit
   list(vector) : Edit/Sort ListView of elements. Build: Enter-value-Enter
      RightClick menu: More (Enter, Alt-M: add new); Less (Alt-L: del last)
   msg(x) : MsgBox `% x

   sign(x) : the sign of x (-1,0,+1)
   rand(x,y) : random number in [x,y]; rand(x) new seed=x.

Float Functions:
   f2c(f) : Fahrenheit -> Centigrade
   c2f(c) : Centigrade -> Fahrenheit

   fcmp(x,y, tol) : floating point comparison with tolerance
   ldexp(x,e) : load exponent -> x * 2**e
   frexp(x, e) : -> scaled x to 0 or [0.5,1); e <- exp: x = frexp(x) * 2**e

   cot(x),  sec(x),  cosec(x)  : trigonometric functions
   acot(x), asec(x), acosec(x) : arcus (inverse) trigonometric functions
   atan2(x,y) : 4-quadrant atan

   sinh(x), cosh(x), tanh(x), coth(x)  : hyperbolic functions
   asinh(x),acosh(x),atanh(x),acoth(x) : inverse hyperbolics

   cbrt(x) : signed cubic root
   quadratic(x1, x2, a,b,c) : -> #real roots {x1,x2} of ax²+bx+c
   cubic(x1, x2, x3, a,b,c,d) :->#real roots {x1,x2,x3} of ax³+bx²+cx+d

Integer functions:
   LCM(a,b) : Least Common Multiple
   GCD(a,b) : Euclidean Greatest Common Divisor
   xGCD(c,d, x,y) : eXtended GCD (returned), compute c,d: GCD = c*x + d*y

   Choose(n,k) : Binomial coefficient. "n.0" force floating point arithmetic
   Fib(n) : n-th Fibonacci number (n < 0 OK, iterative to avoid globals)
   fac(n) : n!
   IsPrime(p) : primality test 0/1

   ModMul(a,b, m) : unsigned a*b mod m, no overflow till a*b < 2**127
   ModPow(a,e, m) : unsigned a**e mod m, no overflow
   uMod(x,m) : unsigned x mod m
   uCmp(a,b) : unsigned 64-bit compare a <,=,> b: -1,0,1
   MsMul(a,b) : Most Significant UInt64 of a*b
   Reci64(m [, ByRef ms]) : Int64 2**ms/m: normalized (negative); unsigned m
   MSb(x) : Most  Significant bit: 1..64, (0 if x=0)
   LSb(x) : Least Significant bit: 1..64, (0 if x=0)

Iterators/Evaluators
   eval(expr) : evaluate ";" separated expressions, [.] index OK
   call(FName,p1=""...,p10="") : evaluate expression in FName,
      sets variables FName1:=p1, FName2:=p2...
   solve('x',x0,x1,'expr'[,tol]) : find 'x' where 'expr' = 0
   fmax('x',x0,x1,x2,'expr'[,tol])) : 'x' where 'expr' = max

   for(Var,i0,i1,d,expr) : evaluate all, return result of last
      {expr(Var:=i0),expr(Var:=i0+d)...}, until i1
   while(cond,expr) : evaluate expr while cond is true; -> last result
   until(expr,cond) : evaluate expr until cond gets true (>= once); -> last

Array creating functions (-> X="X", X_0=length, X_1,X_2... entries):
   copy("X",Y) : duplicates Y
   seq("X",i0,i1[,d=1]) : set up linear sequence X = {i0,i0+d..,i1}
   array("X","i",i0,i1,d, "expr") : X = {expr(i:=i0),expr(i:=i0+d)..,expr(i~=i1)}
   assign("X",entry1...) : assign (<=30) new entries to the of array X
   more("X",entry1...) : add (<=30) new entries to the of array X
   part("Y",X,i0,i1[,d=1]) : Y (!= X) <- {X[i0],X[i0+d]..,X[~i1]}
   join("Z",X,Y) : Z <- join arrays {X,Y}, (Z != X or Y)

   @("Z",X,"op|func",Y="") : elementwise ops, 0-pad; Y or X can be scalar
   plmul("z",y,x) : z <- polynomial y*x (convolution, FIR filter)
   pldiv("q","r",n,d) : polynomial division-mod: q <- n/d; r <- mod(n,d)

   sort("y",x[.opt]) : y <- sorted array x
      opt = 0: random, 1: no duplicates, 2: reverse, 3: reverse+unique
   primes("p",n) : p <- primes till n (Sieve of Eratosthenes)
   pDivs("d",n) : d <- prime divisors of n (increasing)

Vector -> scalar functions
   mean(X), std(X), moment(k,X) : statistics functions
   sum(X), prod(X), sumpow(k,X), dot(X,Y)
   pleval(p,x): evaluate polynomial, <- p(x), (Horner's method)

   min(x,x1=""...,x9="") : min of numbers or one vector
   max(x,x1=""...,x9="") : max of numbers or one vector
   pmean(p, x,x1=""...,x9="") : p-th power mean of numbers or one vector

Graphing functions
   graph(x0,x1,y0,y1,width=400,height=300,BGcolor=white) :
     create/change graph window to plot in, graph() destroys
   Xtick(Array=10,LineColor=gray,LineWidth=1) : add | lines at x positions
     can be called multiple times, BEFORE plot
     Array=integer : equidistant ticks, Array="" : 11 ticks
     Array=float : single line
   Ytick(Array=10,LineColor=gray,LineWidth=1) : add - lines at y positions
   plot(Y,color=blue,LineWidth=2) : add plot of Y with X = {1..len(Y)}
     if no graph paper: create default one
     plot() : erase function graphs
   plotXY(X,Y...): add XY plot to last graph
     if no graph, auto created with graph(min(X),max(X),min(Y),max(Y))

Special constructs:
   [expr] : "_" . eval(expr). x[i] = x_%i%; x[i+1]:=1 OK
   _ : last output
   _1, _2,..._9: earlier outputs (list() shows them)

Math Constants:
   pi = pi        `te   = e
   pi_2 = pi/2    `tln2 = log(2)
   pi23 = 2pi/3   `tlg2 = log10(2)
   pi43 = 4pi/3   `tlge = log10(e)
   pi2 = pi**2    `tln10= ln(10)
   rad = pi/180   `tdeg = 180/pi

Unit conversion constants (150*lb_kg -> 150 pounds = 68.0389 KG)
   inch_cm, foot_cm, mile_km
   oz_l,  pint_l,  gallon_l
   oz_g,  lb_kg
   acre_m2