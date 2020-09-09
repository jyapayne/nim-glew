import macros, nimterop / plugin
import strutils
import sets

template camelCase(str: string): string =
  var res = newStringOfCap(str.len)
  for i in 0..<str.len:
    if str[i] == '_' and i < str.len - 1:
      res.add(str[i+1].toUpperAscii)
    else:
      res.add(str[i])
  res

template lowerFirstLetter(str, rep: string): string =
  if str.startsWith(rep):
    var res = str[rep.len .. ^1]
    res[0] = res[0].toLowerAscii
    res
  else:
    str

template nothing(str, rep: string): string =
  if str.startsWith(rep):
    str[rep.len .. ^1]
  else:
    str

const replacements = [
  "glew",
]

# Symbol renaming examples
proc onSymbol*(sym: var Symbol) {.exportc, dynlib.} =
  if sym.name.startsWith("__"):
    sym.name = sym.name[2..<sym.name.len]
  if sym.name.startsWith("GL_BYTE"):
    sym.name = "CGL_BYTE"
  if sym.name.startsWith("GL_SHORT"):
    sym.name = "CGL_SHORT"
  if sym.name.startsWith("GL_INT"):
    sym.name = "CGL_INT"
  if sym.name.startsWith("GL_FLOAT"):
    sym.name = "CGL_FLOAT"
  if sym.name.startsWith("GL_DOUBLE"):
    sym.name = "CGL_DOUBLE"
  if sym.name.startsWith("GL_FIXED"):
    sym.name = "CGL_FIXED"
  if sym.name.startsWith("PFNGLGETTRANSFORMFEEDBACKIVPROC"):
    sym.name = "CPFNGLGETTRANSFORMFEEDBACKIVPROC"

  if sym.kind == nskProc or sym.kind == nskType or sym.kind == nskConst:
    if sym.name != "_":
      sym.name = sym.name.strip(chars={'_'}).replace("__", "_")

  for rep in replacements:
    if sym.kind == nskProc:
      sym.name = lowerFirstLetter(sym.name, rep)
    else:
      sym.name = nothing(sym.name, rep)

  if sym.kind == nskField:
    sym.name = camelCase(sym.name)
    if sym.name == "type":
      sym.name = "kind"

  if sym.name.startsWith("GetTransformFeedbacki_v"):
    sym.name = sym.name & "u"
