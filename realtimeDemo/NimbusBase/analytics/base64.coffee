"use strict"

global = this

return  if global.Base64
version = "2.1.2"

# if node.js, we use Buffer
buffer = undefined
buffer = require("buffer").Buffer  if typeof module isnt "undefined" and module.exports

# constants
b64chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
b64tab = (bin) ->
  t = {}
  i = 0
  l = bin.length

  while i < l
    t[bin.charAt(i)] = i
    i++
  t
(b64chars)
fromCharCode = String.fromCharCode

# encoder stuff
cb_utob = (c) ->
  if c.length < 2
    cc = c.charCodeAt(0)
    (if cc < 0x80 then c else (if cc < 0x800 then (fromCharCode(0xc0 | (cc >>> 6)) + fromCharCode(0x80 | (cc & 0x3f))) else (fromCharCode(0xe0 | ((cc >>> 12) & 0x0f)) + fromCharCode(0x80 | ((cc >>> 6) & 0x3f)) + fromCharCode(0x80 | (cc & 0x3f)))))
  else
    cc = 0x10000 + (c.charCodeAt(0) - 0xD800) * 0x400 + (c.charCodeAt(1) - 0xDC00)
    fromCharCode(0xf0 | ((cc >>> 18) & 0x07)) + fromCharCode(0x80 | ((cc >>> 12) & 0x3f)) + fromCharCode(0x80 | ((cc >>> 6) & 0x3f)) + fromCharCode(0x80 | (cc & 0x3f))

re_utob = /[\uD800-\uDBFF][\uDC00-\uDFFFF]|[^\x00-\x7F]/g
utob = (u) ->
  u.replace re_utob, cb_utob

cb_encode = (ccc) ->
  padlen = [0, 2, 1][ccc.length % 3]
  ord = ccc.charCodeAt(0) << 16 | (((if ccc.length > 1 then ccc.charCodeAt(1) else 0)) << 8) | ((if ccc.length > 2 then ccc.charCodeAt(2) else 0))
  chars = [b64chars.charAt(ord >>> 18), b64chars.charAt((ord >>> 12) & 63), (if padlen >= 2 then "=" else b64chars.charAt((ord >>> 6) & 63)), (if padlen >= 1 then "=" else b64chars.charAt(ord & 63))]
  chars.join ""

btoa = global.btoa or (b) ->
  b.replace /[\s\S]{1,3}/g, cb_encode

_encode = (if buffer then (u) ->
  (new buffer(u)).toString "base64"
 else (u) ->
  btoa utob(u)
)
encode = (u, urisafe) ->
  (if not urisafe then _encode(u) else _encode(u).replace(/[+\/]/g, (m0) ->
    (if m0 is "+" then "-" else "_")
  ).replace(RegExp("=", "g"), ""))

encodeURI = (u) ->
  encode u, true


# decoder stuff
re_btou = re_btou = new RegExp(['[\xC0-\xDF][\x80-\xBF]', '[\xE0-\xEF][\x80-\xBF]{2}', '[\xF0-\xF7][\x80-\xBF]{3}'].join('|'), 'g')
cb_btou = (cccc) ->
  switch cccc.length
    when 4
      cp = ((0x07 & cccc.charCodeAt(0)) << 18) | ((0x3f & cccc.charCodeAt(1)) << 12) | ((0x3f & cccc.charCodeAt(2)) << 6) | (0x3f & cccc.charCodeAt(3))
      offset = cp - 0x10000
      fromCharCode((offset >>> 10) + 0xD800) + fromCharCode((offset & 0x3FF) + 0xDC00)
    when 3
      fromCharCode ((0x0f & cccc.charCodeAt(0)) << 12) | ((0x3f & cccc.charCodeAt(1)) << 6) | (0x3f & cccc.charCodeAt(2))
    else
      fromCharCode ((0x1f & cccc.charCodeAt(0)) << 6) | (0x3f & cccc.charCodeAt(1))

btou = (b) ->
  b.replace re_btou, cb_btou

cb_decode = (cccc) ->
  len = cccc.length
  padlen = len % 4
  n = ((if len > 0 then b64tab[cccc.charAt(0)] << 18 else 0)) | ((if len > 1 then b64tab[cccc.charAt(1)] << 12 else 0)) | ((if len > 2 then b64tab[cccc.charAt(2)] << 6 else 0)) | ((if len > 3 then b64tab[cccc.charAt(3)] else 0))
  chars = [fromCharCode(n >>> 16), fromCharCode((n >>> 8) & 0xff), fromCharCode(n & 0xff)]
  chars.length -= [0, 0, 2, 1][padlen]
  chars.join ""

atob = global.atob or (a) ->
  a.replace /[\s\S]{1,4}/g, cb_decode

_decode = (if buffer then (a) ->
  (new buffer(a, "base64")).toString()
 else (a) ->
  btou atob(a)
)
decode = (a) ->
  _decode a.replace(/[-_]/g, (m0) ->
    (if m0 is "-" then "+" else "/")
  ).replace(/[^A-Za-z0-9\+\/]/g, "")


# export Base64
global.Base64 =
  VERSION: version
  atob: atob
  btoa: btoa
  fromBase64: decode
  toBase64: encode
  utob: utob
  encode: encode
  encodeURI: encodeURI
  btou: btou
  decode: decode


# if ES5 is available, make Base64.extendString() available
if typeof Object.defineProperty is "function"
  noEnum = (v) ->
    value: v
    enumerable: false
    writable: true
    configurable: true

  global.Base64.extendString = ->
    Object.defineProperty String::, "fromBase64", noEnum(->
      decode this
    )
    Object.defineProperty String::, "toBase64", noEnum((urisafe) ->
      encode this, urisafe
    )
    Object.defineProperty String::, "toBase64URI", noEnum(->
      encode this, true
    )
