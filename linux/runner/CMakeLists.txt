cmake_minimum_required(VERSION 3.13)
project(runner LANGUAGES CXX)

# Define el objetivo de la aplicación. Para cambiar su nombre, modifica
# BINARY_NAME en el CMakeLists.txt raíz, no aquí, o `flutter run` dejará de funcionar.
# Añade aquí los nuevos archivos fuente que incorpores a la aplicación.
# Define the application target. To change its name, change BINARY_NAME in the
# top-level CMakeLists.txt, not the value here, or `flutter run` will no longer
# work.
#
# Any new source files that you add to the application should be added here.
add_executable(${BINARY_NAME}
  "main.cc"
  "my_application.cc"
  "${FLUTTER_MANAGED_DIR}/generated_plugin_registrant.cc"
)

# Aplica la configuración de compilación estándar. Puede eliminarse si la
# aplicación necesita una configuración diferente.
# Apply the standard set of build settings. This can be removed for applications
# that need different build settings.
apply_standard_settings(${BINARY_NAME})

# Añade las definiciones del preprocesador para el identificador de la aplicación.
# Add preprocessor definitions for the application ID.
add_definitions(-DAPPLICATION_ID="${APPLICATION_ID}")

# Añade las bibliotecas necesarias, incluidas las dependencias propias de la aplicación.
# Add dependency libraries. Add any application-specific dependencies here.
target_link_libraries(${BINARY_NAME} PRIVATE flutter)
target_link_libraries(${BINARY_NAME} PRIVATE PkgConfig::GTK)

target_include_directories(${BINARY_NAME} PRIVATE "${CMAKE_SOURCE_DIR}")
