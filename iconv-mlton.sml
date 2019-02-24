structure Iconv :
sig
  exception Iconv of string
  val iconv: string -> string -> string -> string
end
=
struct
  exception Iconv of string
  val () = MLton.Exn.addExnMessager (fn Iconv m => SOME ("Iconv \"" ^ m ^ "\"") | _ => NONE)
  local

    type long = C_Long.t

    val iconv_open_ffi  = _import "iconv_open"  : string * string -> long;
    val iconv_ffi       = _import "iconv"       : long * string ref * int ref * Word8Array.array ref * int ref -> long;
    val iconv_close_ffi = _import "iconv_close" : long -> unit;

 in
    fun iconv from to s =
      let
        val cd = iconv_open_ffi (to ^ "\000", from ^ "\000")
      in
        if cd = ~1 then raise Iconv "open" else
          let
            val maxSymbolSize = 8
            val srcsize = String.size s
            val dstsize = srcsize * 2

            (* val dstmem = Word8Array.unsafeAlloc dstsize *) (* MLton 20180207 *)
            val dstmem = Unsafe.Word8Array.create dstsize (* MLton 20130715 and 20180207 *)

            val src     = ref s
            val srcleft = ref srcsize
            val dst     = ref dstmem
            val dstleft = ref dstsize

            val r = iconv_ffi (cd, src, srcleft, dst, dstleft)
            val _ = iconv_close_ffi cd

          in
            if r = ~1
            then
              (
                if !dstleft < maxSymbolSize
                then raise Iconv "convert: maybe small buffer"
                else raise Iconv "convert"
              )
            else
              Byte.bytesToString (Word8ArraySlice.vector (Word8ArraySlice.slice (dstmem, 0, SOME (dstsize - (!dstleft)))))
          end

      end
 end
end
