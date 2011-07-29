# - Find a LAPACK library
#
# This module will first look in LAPACK_ROOT before considering the default
# system pahts.
# The linker language can be defined by setting the varable LAPACK_LANG
#
# This module defines:
#
#  LAPACK_INCLUDE_DIRS Where to find lapack.h (or equivalent)
#  LAPACK_LIBRARIES Libraries to link against to use LAPACK
#  LAPACK_FOUND Defined if LAPACK is available
#  HAVE_LAPACK To be used in #ifdefs
#  LAPACK_H Name of LAPACK header file
#
# None of the above will be defined unless LAPACK can be found.
#
#=============================================================================
# Copyright 2011 Jonas Juselius <jonas.juselius@uit.no>
#                Radovan Bast   <radovan.bast@uit.no>
#
# Distributed under the OSI-approved BSD License (the "License");
# see accompanying file Copyright.txt for details.
#
# This software is distributed WITHOUT ANY WARRANTY; without even the
# implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
# See the License for more information.
#=============================================================================
# (To distributed this file outside of CMake, substitute the full
#  License text for the above reference.)

include(MathLibFunctions)

if (EXISTS $ENV{MATH_ROOT})
	if (NOT DEFINED LAPACK_ROOT})
		set(LAPACK_ROOT $ENV{MATH_ROOT})
	endif()
endif()

if (EXISTS $ENV{LAPACK_ROOT})
	if (NOT DEFINED LAPACK_ROOT})
		set(LAPACK_ROOT $ENV{LAPACK_ROOT})
	endif()
endif()

# BLAS and LAPACK often go together
if (NOT DEFINED LAPACK_ROOT})
	if (DEFINED BLAS_ROOT})
		set(LAPACK_ROOT ${BLAS_ROOT})
	elseif (EXISTS $ENV{BLAS_ROOT})
		set(LAPACK_ROOT $ENV{BLAS_ROOT})
	endif()
endif()

# Default names for the headers
if (MATH_LANG STREQUAL "C")
	set(lapack_h clapack.h)
endif()
set(lapack_libs lapack)

if (LAPACK_INCLUDE_DIRS AND LAPACK_LIBRARIES)
  set(LAPACK_FIND_QUIETLY TRUE)
endif ()

if (NOT LAPACK_FIND_COMPONENTS)
	set(LAPACK_FIND_COMPONENTS MKL MKL_2011 Atlas default)
endif()

function(find_lapack)
	foreach (lapack ${LAPACK_FIND_COMPONENTS})
		if (${lapack} STREQUAL "MKL")
                    if(${CMAKE_HOST_SYSTEM_PROCESSOR} STREQUAL "x86_64")
                        if(ENABLE_64BIT_INTEGERS)
                            find_mkl("mkl_lapack_ilp64")
                        else()
                            find_mkl("mkl_lapack_lp64")
                        endif()
                    else()
			find_mkl("mkl_lapack")
                    endif()
		elseif (${lapack} STREQUAL "MKL_2011")
                    if(${CMAKE_HOST_SYSTEM_PROCESSOR} STREQUAL "x86_64")
                        if(ENABLE_64BIT_INTEGERS)
                            find_mkl("mkl_lapack95_ilp64")
                        else()
                            find_mkl("mkl_lapack95_lp64")
                        endif()
                    else()
			find_mkl("mkl_lapack95")
                    endif()
		elseif (${lapack} STREQUAL "Atlas")
			find_atlas()
		else()
			find_default()
		endif()
		if (LAPACK_FOUND)
			break()
		endif()
	endforeach()
endfunction()

macro(find_default)
	set(lapack_libs lapack)
	set(path_suffixes lib)
	find_math_header(lapack)
	find_math_libs(lapack)
	cache_math_result(default lapack)
endmacro()

macro(find_atlas)
	set(lapack_libs lapack_atlas)

	set(path_suffixes include/atlas include)
	find_math_header(lapack)
	set(path_suffixes lib lib/atlas)
	find_math_libs(lapack)
	cache_math_result(Atlas lapack)
endmacro()

macro(find_mkl _name)
	if(${CMAKE_HOST_SYSTEM_PROCESSOR} STREQUAL "x86_64")
		set(path_suffixes lib/intel64 lib/em64t)
	else()
		set(path_suffixes lib/ia32 lib/32)
	endif()
	set(lapack_libs ${_name})

	find_math_header(lapack)
	find_math_libs(lapack)

	if(lapack_libraries)
		set(lapack_libraries
			-Wl,--start-group ${lapack_libraries} -Wl,--end-group )
	endif()
	cache_math_result(MKL lapack)
endmacro()

find_lapack()

if(LAPACK_LIBRARIES)
   set(LAPACK_FOUND TRUE)
endif()

unset(lapack_h)
unset(lapack_libs)
