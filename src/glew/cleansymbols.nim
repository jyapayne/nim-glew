import macros, nimterop / plugin
import strutils, regex
import sets

proc firstLetterLower(m: RegexMatch, s: string): string =
  if m.groupsCount > 0 and m.group(0).len > 0:
    return s[m.group(0)[0]].toLowerAscii

proc camelCase(m: RegexMatch, s: string): string =
  if m.groupsCount > 0 and m.group(0).len > 0:
    return s[m.group(0)[0]].toUpperAscii

proc nothing(m: RegexMatch, s: string): string =
  if m.groupsCount > 0 and m.group(0).len > 0:
    return s[m.group(0)[0]]

const replacements = [
  re"^glew(.)",
]

const underscoreReg = re"_(.)"

# Symbol renaming examples
proc onSymbol*(sym: var Symbol) {.exportc, dynlib.} =
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
      try:
        sym.name = sym.name.replace(rep, firstLetterLower)
      except:
        discard
    else:
      try:
        sym.name = sym.name.replace(rep, nothing)
      except:
        discard

  if sym.kind == nskField:
    sym.name = sym.name.replace(underscoreReg, camelCase)
    if sym.name == "type":
      sym.name = "kind"
