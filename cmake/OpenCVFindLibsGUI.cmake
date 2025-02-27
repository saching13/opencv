# ----------------------------------------------------------------------------
#  Detect 3rd-party GUI libraries
# ----------------------------------------------------------------------------

# --- QT4/5 ---
ocv_clear_vars(HAVE_QT HAVE_QT5)

macro(ocv_find_package_Qt4)
  find_package(Qt4 COMPONENTS QtCore QtGui QtTest ${ARGN})
  if(QT4_FOUND)
    set(QT_FOUND 1)
    ocv_assert(QT_VERSION_MAJOR EQUAL 4)
  endif()
endmacro()

macro(ocv_find_package_Qt OCV_QT_VER)
  find_package(Qt${OCV_QT_VER} COMPONENTS Core Gui Widgets Test Concurrent ${ARGN} NO_MODULE)
  if(Qt${OCV_QT_VER}_FOUND)
    set(QT_FOUND 1)
    set(QT_VERSION "${Qt${OCV_QT_VER}_VERSION}")
    set(QT_VERSION_MAJOR "${Qt${OCV_QT_VER}_VERSION_MAJOR}")
    set(QT_VERSION_MINOR "${Qt${OCV_QT_VER}_VERSION_MINOR}")
    set(QT_VERSION_PATCH "${Qt${OCV_QT_VER}_VERSION_PATCH}")
    set(QT_VERSION_TWEAK "${Qt${OCV_QT_VER}_VERSION_TWEAK}")
    set(QT_VERSION_COUNT "${Qt${OCV_QT_VER}_VERSION_COUNT}")
  endif()
endmacro()

if(WITH_QT)
  if(NOT WITH_QT GREATER 0)
    # BUG: Qt5Config.cmake script can't handle components properly: find_package(QT NAMES Qt6 Qt5 REQUIRED NO_MODULE COMPONENTS Core Gui Widgets Test Concurrent)
    ocv_find_package_Qt(6 QUIET)
    if(NOT QT_FOUND)
      hunter_add_package(Qt)
      find_package(Qt5Core)
      find_package(Qt5Gui)
      find_package(Qt5Widgets)
      find_package(Qt5Test)
      find_package(Qt5Concurrent)

      ocv_find_package_Qt(5 QUIET)
    endif()
    if(NOT QT_FOUND)
      ocv_find_package_Qt4(QUIET)
    endif()
  elseif(WITH_QT EQUAL 4)
    ocv_find_package_Qt4(REQUIRED)
  else()  # WITH_QT=<major version>
    ocv_find_package_Qt("${WITH_QT}" REQUIRED)
  endif()
  if(QT_FOUND)
    set(HAVE_QT ON)
    if(QT_VERSION_MAJOR GREATER 4)
      find_package(Qt${QT_VERSION_MAJOR} COMPONENTS OpenGL QUIET)
      if(Qt${QT_VERSION_MAJOR}OpenGL_FOUND)
        set(QT_QTOPENGL_FOUND ON)  # HAVE_QT_OPENGL is defined below
        if(QT_VERSION_MAJOR GREATER 5) # QGL -> QOpenGL
          find_package(Qt${QT_VERSION_MAJOR} COMPONENTS OpenGLWidgets QUIET)
          if(NOT Qt${QT_VERSION_MAJOR}OpenGLWidgets_FOUND)
            message(STATUS "Qt OpenGLWidgets component not found: turning off Qt OpenGL functionality")
            set(QT_QTOPENGL_FOUND FALSE)
          endif()
        endif()
      endif()
    endif()
  endif()
endif()

# --- OpenGl ---
ocv_clear_vars(HAVE_OPENGL HAVE_QT_OPENGL)
if(WITH_OPENGL)
  if(WITH_WIN32UI OR (HAVE_QT AND QT_QTOPENGL_FOUND) OR HAVE_GTKGLEXT)
    find_package (OpenGL QUIET)
    if(OPENGL_FOUND)
      set(HAVE_OPENGL TRUE)
      if(QT_QTOPENGL_FOUND)
        set(HAVE_QT_OPENGL TRUE)
      else()
        ocv_include_directories(${OPENGL_INCLUDE_DIR})
      endif()
    endif()
  endif()
endif(WITH_OPENGL)

# --- Cocoa ---
if(APPLE)
  if(NOT IOS AND CV_CLANG)
    set(HAVE_COCOA YES)
  endif()
endif()
