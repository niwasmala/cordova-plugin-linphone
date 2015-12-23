#----------------------------------------------------------------
# Generated CMake target import file for configuration "Release".
#----------------------------------------------------------------

# Commands may need to know the format version.
set(CMAKE_IMPORT_FILE_VERSION 1)

# Import target "BelledonneCommunications::bzrtp" for configuration "Release"
set_property(TARGET BelledonneCommunications::bzrtp APPEND PROPERTY IMPORTED_CONFIGURATIONS RELEASE)
set_target_properties(BelledonneCommunications::bzrtp PROPERTIES
  IMPORTED_LINK_INTERFACE_LANGUAGES_RELEASE "C"
  IMPORTED_LOCATION_RELEASE "${_IMPORT_PREFIX}/lib/libbzrtp.a"
  )

list(APPEND _IMPORT_CHECK_TARGETS BelledonneCommunications::bzrtp )
list(APPEND _IMPORT_CHECK_FILES_FOR_BelledonneCommunications::bzrtp "${_IMPORT_PREFIX}/lib/libbzrtp.a" )

# Commands beyond this point should not need to know the version.
set(CMAKE_IMPORT_FILE_VERSION)
