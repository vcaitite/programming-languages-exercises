(* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++
Developer: Vítor Caitité - 2016111849
Exercise 6 - Parte 2
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ *)

(* For our language, the meta-variables and categories
are as follows:
- n will range over numerals, Num,
- x will range over variables, Var,
- a will range over arithmetic expressions, Aexp,
- b will range over boolean expressions, Bexp, and
- S will range over statements, Stm *)

type Num = int ;
type Var = string ;

datatype Aexpr = N of Num
               | V of Var
               | Plus of Aexpr * Aexpr
               | Mult of Aexpr * Aexpr
               | Minus of Aexpr * Aexpr ;

datatype Bexpr = True
               | False
               | Eq of Aexpr * Aexpr
               | Leq of Aexpr * Aexpr
               | Not of Bexpr
               | And of Bexpr * Bexpr ;

datatype Stm = Assign of Var * Aexpr
             | Skip
             | Comp of Stm * Stm
             | If of Bexpr * Stm * Stm
             | While of Bexpr * Stm
             | Repeat of Stm * Bexpr ;

fun evalN n : Num = n

exception FreeVar ;
fun lookup [] id = raise FreeVar
  | lookup (( k : string , v ) :: l ) id = if id = k then v else lookup l id ;

fun evalA ( N n ) _ = evalN n
  | evalA ( V x ) s = lookup s x
  | evalA ( Plus ( e1 , e2 ) ) s = ( evalA e1 s ) + ( evalA e2 s )
  | evalA ( Mult ( e1 , e2 ) ) s = ( evalA e1 s ) * ( evalA e2 s )
  | evalA ( Minus ( e1 , e2 ) ) s = ( evalA e1 s ) - ( evalA e2 s ) ;

fun evalB True _ = true
  | evalB False _ = false
  | evalB ( Eq ( a1 , a2 ) ) s = ( evalA a1 s ) = ( evalA a2 s )
  | evalB ( Leq ( a1 , a2 ) ) s = ( evalA a1 s ) <= ( evalA a2 s )
  | evalB ( Not b ) s = not ( evalB b s )
  | evalB ( And ( b1 , b2 ) ) s = ( evalB b1 s ) andalso ( evalB b2 s ) ;

fun evalStm ( stm : Stm ) ( s : ( string * int ) list ) : ( string * int ) list =
  case stm of
    ( Assign (x , a ) ) => (x , evalA a s ) :: s
    | Skip => s
    | ( Comp ( stm1 , stm2 ) ) => evalStm stm2 ( evalStm stm1 s )
    | ( If (b , stm1 , stm2 ) ) => if ( evalB b s ) then evalStm stm1 s else evalStm stm2 s
    | ( While (b , stm1 ) ) =>
        if ( evalB b s ) then
          let
            val newS = evalStm stm1 s;
          in
            evalStm stm newS
          end
        else s
    | ( Repeat ( stm1 , b ) ) =>
        let
          val newS = evalStm stm1 s
          val evB = evalB b newS;
        in
          if evB then newS else evalStm stm newS
        end;
