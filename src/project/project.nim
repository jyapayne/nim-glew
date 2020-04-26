import os, strutils, strformat
import nimterop/[cimport, build]

const
  ProjectCacheDir* = currentSourcePath.parentDir().parentDir() / "build" #getProjectCacheDir("nimsdl2")
  baseDir = SDLCacheDir
  srcDir = baseDir / "sdl2"
  buildDir = srcDir / "buildcache"
  symbolPluginPath = currentSourcePath.parentDir() / "cleansymbols.nim"

getHeader(
  "template.h",
  dlurl = "https://download.com/template-$1.tar.gz",
  outdir = srcDir,
  cmakeFlags = "-F flag",
  conFlags = "-F flag"
)

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

cOverride:
  discard

cPluginPath(symbolPluginPath)

when defined(Project_Static):
  cImport(Project_Path, recurse = true, flags = "-f=ast2 -E__,_ -F__,_")
else:
  cImport(Project_Path, recurse = true, dynlib = "Project_LPath", flags = "-f=ast2 -E__,_ -F__,_")
