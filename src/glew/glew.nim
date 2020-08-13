import os, strutils, strformat
import nimterop/[cimport, build, globals]

const
  ProjectCacheDir* = getProjectCacheDir("nimglew")
  baseDir = ProjectCacheDir.sanitizePath
  srcDir = baseDir / "glew"
  buildDir = srcDir / "lib"
  includeDir = srcDir / "include"
  symbolPluginPath = currentSourcePath.parentDir() / "cleansymbols.nim"

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
  altNames = "libGLEW",
  conFlags = flags,
  buildTypes = [btAutoConf]
)

cIncludeDir(includeDir)

static:
  discard
  # gitPull("https://github.com/lib/project", outdir=srcDir, plist="""
# src/*.h
# src/*.c
# """, checkout = "1f9c8864fc556a1be4d4bf1d6bfe20cde25734b4")
  # cSkipSymbol @[]
  # cDebug()
  # cDisableCaching()
  # let contents = readFile(srcDir/"src"/"dynapi"/"SDL_dynapi_procs.h")
  # writeFile(srcDir/"src"/"dynapi"/"SDL_dynapi_procs.c", contents


cPluginPath(symbolPluginPath)

when defined(glewStatic):
  cImport(glewPath, recurse = true, flags = "-f=ast2 -H -E__,_ -F__,_")
else:
  cImport(glewPath, recurse = true, dynlib = "glewLPath", flags = "-f=ast2 -H -E__,_ -F__,_")
