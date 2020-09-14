import opengl
import glfw
import glew

proc main() =
  initHint(CONTEXT_VERSION_MAJOR, 3)
  initHint(CONTEXT_VERSION_MINOR, 2)
  when defined(macosx):
    initHint(OPENGL_FORWARD_COMPAT, 1)
  initHint(OPENGL_PROFILE, OPENGL_CORE_PROFILE)

  discard glfw.init()

  windowHint(CONTEXT_VERSION_MAJOR, 3)
  windowHint(CONTEXT_VERSION_MINOR, 2)
  when defined(macosx):
    windowHint(OPENGL_FORWARD_COMPAT, 1)
  windowHint(OPENGL_PROFILE, OPENGL_CORE_PROFILE)

  var w = createWindow(800, 600, "Minimal Nim-GLFW Example", nil, nil)
  w.makeContextCurrent()

  let code = glew.init()

  if code != GLEW_OK:
    raise newException(CatchableError, "Glew not initialized properly")

main()
