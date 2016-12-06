open Iconv


fun readFile () =
  let
    val args = CommandLine.arguments()
    val _ = if List.null args then print "Set file as argument.\n" else ()
    val file = List.nth(args, 0)
  in
    TextIO.inputAll (TextIO.openIn file)
  end

fun main' () =
  let
    val s = readFile ()
    val n = iconv "CP1251" "UTF-8" s
  in
    print ( n ^ "\n")
  end


fun main () = main' () handle exc => print ("function main raised an exception: " ^ exnMessage exc ^ "\n")
