structure Iconv :
sig
  exception Iconv of string
  val iconv: string -> string -> string -> string
end
=
struct
  exception Iconv of string
  local
    open Foreign

    val libc = loadExecutable ()

    (* if iconv is missing in libc then libiconv used *)
    val (libc, symbolPrefix) = ( symbolAsAddress (getSymbol libc "iconv"); (libc, "") )
       handle exc => case exc of
           (Foreign _) => (loadLibrary "libiconv.so", "lib")
         | _ => raise exc

    val iconv_open_ffi  = buildCall2 ((getSymbol libc (symbolPrefix ^ "iconv_open")), (cString, cString), cLong)
    val iconv_ffi       = buildCall5 ((getSymbol libc (symbolPrefix ^ "iconv")), (cLong, cStar cPointer, cStar cLong, cStar cPointer, cStar cLong), cLong)
    val iconv_close_ffi = buildCall1 ((getSymbol libc (symbolPrefix ^ "iconv_close")), cLong, cInt)


 in
    fun iconv from to s =
      let
        val cd = iconv_open_ffi (to, from)
      in
        if cd = ~1 then raise Iconv "open" else
          let
            val maxSymbolSize = 8
            val srcsize = String.size s
            val dstsize = srcsize * 2

            val srcmem = Memory.malloc (Word.fromInt srcsize)
            val dstmem = Memory.malloc (Word.fromInt dstsize)

            val () = CharVector.appi (fn (i, ch) => Memory.set8 (srcmem, Word.fromInt i, Byte.charToByte ch)) s

            val src     = ref srcmem
            val srcleft = ref srcsize
            val dst     = ref dstmem
            val dstleft = ref dstsize

            val r = iconv_ffi (cd, src, srcleft, dst, dstleft)
            val _ = iconv_close_ffi cd

          in
            if r = ~1
            then
              (
                Memory.free dstmem;
                Memory.free srcmem;
                if !dstleft < maxSymbolSize
                then raise Iconv "convert: maybe small buffer"
                else raise Iconv "convert"
              )
            else
              let
                val rs = CharVector.tabulate (dstsize - (!dstleft), fn i => Byte.byteToChar (Memory.get8 (dstmem, Word.fromInt i)))
              in
                Memory.free dstmem;
                Memory.free srcmem;
                rs
              end
          end

      end
 end
end
