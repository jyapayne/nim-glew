import macros
import os, strutils, strformat
import nimterop/[cimport, build, globals]

const
  ProjectCacheDir* = getProjectCacheDir("nimglew")
  baseDir = ProjectCacheDir.sanitizePath
  srcDir = baseDir / "glew"
  buildDir = srcDir / "lib"
  includeDir = srcDir / "include"
  currentPath = getProjectPath().parentDir().sanitizePath
  generatedPath = (currentPath / "generated" / "glew").replace("\\", "/")
  symbolPluginPath = currentSourcePath.parentDir() / "cleansymbols.nim"

setDefines(@["glewSetVer=2.1.0", "glewDL", "glewStatic"])

when defined(windows):
  when defined(amd64):
    const flags = &"--libdir={buildDir} --includedir={includeDir} --host=x86_64-w64-mingw32"
  else:
    const flags = &"--libdir={buildDir} --includedir={includeDir} --host=i686-w64-mingw32"
else:
  const flags = &"--libdir={buildDir} --includedir={includeDir}"

static:
  putEnv("GLEW_PREFIX", srcDir)
  putEnv("GLEW_DEST", srcDir)
  let pathenv = getEnv("PATH")
  putEnv("PATH", &"{includeDir}:{buildDir}:{pathenv}")

getHeader(
  "glew.h",
  dlurl = "https://github.com/nigels-com/glew/releases/download/glew-$1/glew-$1.zip",
  outdir = srcDir,
  altNames = "libGLEW,glew,libglew",
  conFlags = flags,
  buildTypes = [btAutoConf]
)

cIncludeDir(includeDir)

static:
  discard
  # cSkipSymbol @[]
  # cDebug()
  # cDisableCaching()


cPluginPath(symbolPluginPath)

when isDefined(glewStatic):
  cImport(glewPath, recurse = true, flags = "-f=ast2 -H -E__,_ -F__,_", nimFile = generatedPath / "glew.nim")
else:
  cImport(glewPath, recurse = true, dynlib = "glewLPath", flags = "-f=ast2 -H -E__,_ -F__,_", nimFile = generatedPath / "glew.nim")
