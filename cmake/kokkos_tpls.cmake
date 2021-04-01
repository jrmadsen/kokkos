KOKKOS_CFG_DEPENDS(TPLS OPTIONS)
KOKKOS_CFG_DEPENDS(TPLS DEVICES)
KOKKOS_CFG_DEPENDS(TPLS COMPILER_ID)

FUNCTION(KOKKOS_TPL_OPTION PKG DEFAULT)
  CMAKE_PARSE_ARGUMENTS(PARSED
    ""
    "TRIBITS"
    ""
    ${ARGN})

  IF (PARSED_TRIBITS)
    #this is also a TPL option you can activate with Tribits
    IF (NOT "${TPL_ENABLE_${PARSED_TRIBITS}}" STREQUAL "")
      #Tribits brought its own default that should take precedence
      SET(DEFAULT ${TPL_ENABLE_${PARSED_TRIBITS}})
    ENDIF()
  ENDIF()

  KOKKOS_ENABLE_OPTION(${PKG} ${DEFAULT} "Whether to enable the ${PKG} library")
  KOKKOS_OPTION(${PKG}_DIR "" PATH "Location of ${PKG} library")
  SET(KOKKOS_ENABLE_${PKG} ${KOKKOS_ENABLE_${PKG}} PARENT_SCOPE)
  SET(KOKKOS_${PKG}_DIR  ${KOKKOS_${PKG}_DIR} PARENT_SCOPE)

  IF (KOKKOS_HAS_TRILINOS
    AND KOKKOS_ENABLE_${PKG}
    AND NOT PARSED_TRIBITS)
    #this TPL was enabled, but it is not valid to use inside of TriBITS
    MESSAGE(FATAL_ERROR "Enabled TPL ${PKG} inside TriBITS build, "
           "but this can only be enabled in a standalone build")
  ENDIF()
ENDFUNCTION()

KOKKOS_TPL_OPTION(HWLOC   Off)
KOKKOS_TPL_OPTION(LIBNUMA Off)
KOKKOS_TPL_OPTION(MEMKIND Off)
IF(KOKKOS_ENABLE_MEMKIND)
  SET(KOKKOS_ENABLE_HBWSPACE ON)
ENDIF()
KOKKOS_TPL_OPTION(CUDA    ${Kokkos_ENABLE_CUDA} TRIBITS CUDA)
KOKKOS_TPL_OPTION(LIBRT   Off)
IF(KOKKOS_ENABLE_HIP AND NOT KOKKOS_CXX_COMPILER_ID STREQUAL HIPCC)
  SET(ROCM_DEFAULT ON)
ELSE()
  SET(ROCM_DEFAULT OFF)
ENDIF()
KOKKOS_TPL_OPTION(ROCM    ${ROCM_DEFAULT})

IF (WIN32)
  SET(LIBDL_DEFAULT Off)
ELSE()
  SET(LIBDL_DEFAULT On)
ENDIF()
KOKKOS_TPL_OPTION(LIBDL ${LIBDL_DEFAULT} TRIBITS DLlib)

IF(Trilinos_ENABLE_Kokkos AND TPL_ENABLE_HPX)
SET(HPX_DEFAULT ON)
ELSE()
SET(HPX_DEFAULT OFF)
ENDIF()
KOKKOS_TPL_OPTION(HPX ${HPX_DEFAULT})

IF(Trilinos_ENABLE_Kokkos AND TPL_ENABLE_PTHREAD)
SET(PTHREAD_DEFAULT ON)
ELSE()
SET(PTHREAD_DEFAULT OFF)
ENDIF()
KOKKOS_TPL_OPTION(PTHREAD ${PTHREAD_DEFAULT} TRIBITS Pthread)


#Make sure we use our local FindKokkosCuda.cmake
KOKKOS_IMPORT_TPL(HPX INTERFACE)
KOKKOS_IMPORT_TPL(CUDA INTERFACE)
KOKKOS_IMPORT_TPL(HWLOC)
KOKKOS_IMPORT_TPL(LIBNUMA)
KOKKOS_IMPORT_TPL(LIBRT)
KOKKOS_IMPORT_TPL(LIBDL)
KOKKOS_IMPORT_TPL(MEMKIND)
KOKKOS_IMPORT_TPL(PTHREAD INTERFACE)
KOKKOS_IMPORT_TPL(ROCM INTERFACE)

#Convert list to newlines (which CMake doesn't always like in cache variables)
STRING(REPLACE ";" "\n" KOKKOS_TPL_EXPORT_TEMP "${KOKKOS_TPL_EXPORTS}")
#Convert to a regular variable
UNSET(KOKKOS_TPL_EXPORTS CACHE)
SET(KOKKOS_TPL_EXPORTS ${KOKKOS_TPL_EXPORT_TEMP})
IF (KOKKOS_ENABLE_MEMKIND)
   SET(KOKKOS_ENABLE_HBWSPACE)
   LIST(APPEND KOKKOS_MEMSPACE_LIST HBWSpace)
ENDIF()

KOKKOS_OPTION(ENABLE_COMPILE_TIME_PERF OFF BOOL "Enable per-file compile time measurements")
IF(Kokkos_ENABLE_COMPILE_TIME_PERF)
    FIND_PACKAGE(compile-time-perf REQUIRED)
    enable_compile_time_perf(kokkos-compile-time)
ENDIF()
