import os, strutils, strformat
import nimterop/[cimport, build]

const
  ProjectCacheDir* = getProjectCacheDir("nimglew")
  baseDir = ProjectCacheDir
  srcDir = baseDir / "glew"
  buildDir = srcDir / "buildcache"
  symbolPluginPath = currentSourcePath.parentDir() / "cleansymbols.nim"

getHeader(
  "glew.h",
  dlurl = "https://github.com/nigels-com/glew/releases/download/glew-$1/glew-$1.zip",
  outdir = srcDir,
  altNames = "libGLEW"
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


cPluginPath(symbolPluginPath)

when defined(glewStatic):
  cImport(glewPath, recurse = true, flags = "-f=ast2 -E__,_ -F__,_")
else:
  cImport(glewPath, recurse = true, dynlib = "glewLPath", flags = "-f=ast2 -E__,_ -F__,_")
