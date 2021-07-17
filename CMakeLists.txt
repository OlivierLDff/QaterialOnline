
cmake_minimum_required(VERSION 3.14)

project(QaterialOnline LANGUAGES CXX VERSION 1.0.0)

set(QTSTATICCMAKE_REPOSITORY "https://github.com/OlivierLDff/QtStaticCMake.git" CACHE STRING "QtStaticCMake repository, can be a local URL")
set(QTSTATICCMAKE_TAG "v1.1.0" CACHE STRING "QtStaticCMake git tag")

# Find all required package, if some is missing it will result in error in target_link_libraries
find_package(Qt5 COMPONENTS Core            REQUIRED)
find_package(Qt5 COMPONENTS Gui             REQUIRED)
find_package(Qt5 COMPONENTS Qml             REQUIRED)
find_package(Qt5 COMPONENTS QmlWorkerScript QUIET   )
find_package(Qt5 COMPONENTS Quick           REQUIRED)
find_package(Qt5 COMPONENTS QuickControls2  REQUIRED)
find_package(Qt5 COMPONENTS Svg             REQUIRED)
find_package(Qt5 COMPONENTS Xml             REQUIRED)

find_package(Qt5 COMPONENTS DataVisualization     REQUIRED)
find_package(Qt5 COMPONENTS Charts                REQUIRED)
find_package(Qt5 COMPONENTS TextToSpeech          REQUIRED)

find_package(Qt5 COMPONENTS WebChannel            REQUIRED)
find_package(Qt5 COMPONENTS WebSockets            REQUIRED)

find_package(Qt5 COMPONENTS Quick3D               REQUIRED)
find_package(Qt5 COMPONENTS Quick3DAssetImport    REQUIRED)
find_package(Qt5 COMPONENTS Quick3DRender         REQUIRED)
find_package(Qt5 COMPONENTS Quick3DRuntimeRender  REQUIRED)
find_package(Qt5 COMPONENTS Quick3DUtils          REQUIRED)

include(cmake/FetchQaterial.cmake)

add_executable(QaterialOnline
  src/main.cpp
  src/util.cpp
  src/util.h
  src/version.cpp
  src/version.h
  qml/qml.qrc)

# Require cmake 3.8 but way nicer than writing to global CMAKE_CXX_STANDARD
target_compile_features(QaterialOnline PUBLIC cxx_std_14)

# Better to use the target PROPERTIES and not global set(CMAKE_AUTOMOC ON)
# Otherwise if superbuild, moc will try to moc dependencies too.
set_target_properties(QaterialOnline PROPERTIES AUTORCC TRUE)
set_target_properties(QaterialOnline PROPERTIES AUTOMOC TRUE)

# target_link_libraries and not qt5_use_module because it is deprecated
target_link_libraries(QaterialOnline PRIVATE
  Qt5::Core
  Qt5::Gui
  Qt5::Svg
  Qt5::Xml
  Qt5::Qml
  Qt5::Quick
  Qt5::QuickControls2
  Qt5::DataVisualization
  Qt5::Charts
  Qt5::TextToSpeech
  Qt5::WebChannel
  Qt5::WebSockets
  Qt5::Quick3D
  Qt5::Quick3DAssetImport
  Qt5::Quick3DRender
  Qt5::Quick3DRuntimeRender
  Qt5::Quick3DUtils
  Qaterial
)

# Only use static macro if linking with static qt
get_target_property(QT_TARGET_TYPE Qt5::Core TYPE)
if(${QT_TARGET_TYPE} STREQUAL "STATIC_LIBRARY")
  include(cmake/FetchQtStaticCMake.cmake)

  qt_generate_plugin_import(QaterialOnline VERBOSE)

  # EXTRA_PLUGIN are the one required by plugin loaded by qt_generate_plugin_import
  # It's not automatic yet :( All this workflow might change in future version of qt
  # with better and better cmake support
  qt_generate_qml_plugin_import(QaterialOnline
    QML_SRC ${CMAKE_CURRENT_SOURCE_DIR}/qml
    EXTRA_PLUGIN
      QtQuickVirtualKeyboardPlugin
      QtQuickVirtualKeyboardSettingsPlugin
      QtQuickVirtualKeyboardStylesPlugin
      QmlFolderListModelPlugin
      QQuickLayoutsPlugin
    VERBOSE
  )

endif()

# This target needs to be linked after qt_generate_qml_plugin_import call.
# This is hiding a bug somewhere ...
if(TARGET Qt5::QmlWorkerScript)
  target_link_libraries(QaterialOnline PRIVATE Qt5::QmlWorkerScript)
endif()

string(TIMESTAMP _QATERIALONLINE_BUILD_DATE "%d/%m/%Y - %H:%M:%S")

if(EXISTS "${qaterial_SOURCE_DIR}/.git")
  execute_process(
    COMMAND git rev-parse --short HEAD
    WORKING_DIRECTORY ${qaterial_SOURCE_DIR}
    OUTPUT_VARIABLE _QATERIALONLINE_VERSION
    OUTPUT_STRIP_TRAILING_WHITESPACE
  )
  message(STATUS "_QATERIALONLINE_VERSION : ${_QATERIALONLINE_VERSION}")
endif()

if(NOT _QATERIALONLINE_VERSION)
  set(_QATERIALONLINE_VERSION "00000000")
endif()

set(QATERIALONLINE_VERSION ${_QATERIALONLINE_VERSION} CACHE STRING "Version of QaterialOnline (default to version of Qaterial)")
set(QATERIALONLINE_BUILD_DATE ${_QATERIALONLINE_BUILD_DATE} CACHE STRING "QaterialOnline Build date")
set(QATERIALONLINE_BUILD_RUN_NUMBER "1" CACHE STRING "QaterialOnline Build Number")
set(QATERIALONLINE_BUILD_RUN_ID  "1" CACHE STRING "QaterialOnline Build Id")

target_compile_definitions(QaterialOnline PRIVATE
  QATERIALONLINE_VERSION=\"${QATERIALONLINE_VERSION}\"
  QATERIALONLINE_BUILD_DATE=\"${QATERIALONLINE_BUILD_DATE}\"
  QATERIALONLINE_BUILD_RUN_NUMBER=\"${QATERIALONLINE_BUILD_RUN_NUMBER}\"
  QATERIALONLINE_BUILD_RUN_ID=\"${QATERIALONLINE_BUILD_RUN_ID}\"
)

if(${CMAKE_SYSTEM_NAME} STREQUAL "Emscripten")
  set(QATERIALONLINE_DEPLOY_FOLDER "${CMAKE_CURRENT_BINARY_DIR}/deploy/")

  set_target_properties(QaterialOnline
    PROPERTIES
    ARCHIVE_OUTPUT_DIRECTORY "${QATERIALONLINE_DEPLOY_FOLDER}"
    LIBRARY_OUTPUT_DIRECTORY "${QATERIALONLINE_DEPLOY_FOLDER}"
    RUNTIME_OUTPUT_DIRECTORY "${QATERIALONLINE_DEPLOY_FOLDER}"
  )

  # Generate example.js

  # Match all files, and filter with IS_DIRECTORY later
  file(GLOB QATERIALONLINE_EXAMPLES_DIR "${Qaterial_SOURCE_DIR}/examples/*")
  set(QATERIALONLINE_EXAMPLES_FILE "${CMAKE_CURRENT_BINARY_DIR}/examples.js")
  file(WRITE ${QATERIALONLINE_EXAMPLES_FILE} "function getExamples() {\n"
    "  return {\n")
  foreach(EXAMPLE_DIR ${QATERIALONLINE_EXAMPLES_DIR})
    if(IS_DIRECTORY "${EXAMPLE_DIR}")
      get_filename_component(EXAMPLE_DIRNAME ${EXAMPLE_DIR} NAME)
      message(STATUS "Add example dir ${EXAMPLE_DIR}, dir is ${EXAMPLE_DIRNAME}")
      file(APPEND ${QATERIALONLINE_EXAMPLES_FILE} "    ${EXAMPLE_DIRNAME}: [\n")

      # Find all qml files and create entry
      file(GLOB QATERIALONLINE_EXAMPLES "${EXAMPLE_DIR}/*.qml")
      foreach(EXAMPLE ${QATERIALONLINE_EXAMPLES})

        get_filename_component(EXAMPLE_FILENAME_WE ${EXAMPLE} NAME_WE)
        get_filename_component(EXAMPLE_FILENAME ${EXAMPLE} NAME)

        message(STATUS "Add example ${EXAMPLE} in ${EXAMPLE_DIRNAME}, file is ${EXAMPLE_FILENAME}")

        file(APPEND ${QATERIALONLINE_EXAMPLES_FILE} "      {\n"
          "        name: \"${EXAMPLE_FILENAME_WE}\",\n"
          "        file: \"examples/${EXAMPLE_DIRNAME}/${EXAMPLE_FILENAME}\",\n"
          "      },\n")

        add_custom_command(TARGET QaterialOnline POST_BUILD
          COMMAND ${CMAKE_COMMAND} -E make_directory "${QATERIALONLINE_DEPLOY_FOLDER}/examples/${EXAMPLE_DIRNAME}"
          COMMAND ${CMAKE_COMMAND} -E copy_if_different "${EXAMPLE}" "${QATERIALONLINE_DEPLOY_FOLDER}/examples/${EXAMPLE_DIRNAME}"
          COMMENT "Deploy ${EXAMPLE} to ${QATERIALONLINE_DEPLOY_FOLDER}/examples/${EXAMPLE_DIRNAME}")

      endforeach()

      file(APPEND ${QATERIALONLINE_EXAMPLES_FILE} "    ],\n")

    endif()
  endforeach()

  file(APPEND ${QATERIALONLINE_EXAMPLES_FILE} "  }\n}\n")

  # Deploy example.js

  add_custom_command(TARGET QaterialOnline POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E copy_if_different "${QATERIALONLINE_EXAMPLES_FILE}" ${QATERIALONLINE_DEPLOY_FOLDER}
    COMMENT "Deploy ${QATERIALONLINE_EXAMPLES_FILE} to ${QATERIALONLINE_DEPLOY_FOLDER}")

  # Deploy html sources

  set(QATERIALONLINE_HTML_SRC
    html/index.html
    html/qml.js
    html/styles.css
    html/icon.png)

  foreach(SRC ${QATERIALONLINE_HTML_SRC})
    add_custom_command(TARGET QaterialOnline POST_BUILD
      COMMAND ${CMAKE_COMMAND} -E copy_if_different "${CMAKE_CURRENT_SOURCE_DIR}/${SRC}" ${QATERIALONLINE_DEPLOY_FOLDER}
      DEPENDS "${CMAKE_CURRENT_SOURCE_DIR}/${SRC}"
      COMMENT "Deploy ${SRC} to ${QATERIALONLINE_DEPLOY_FOLDER}")
  endforeach()

  include(cmake/FetchQtWasmCMake.cmake)
  add_qt_wasm_app(QaterialOnline INITIAL_MEMORY 40MB)
endif()
