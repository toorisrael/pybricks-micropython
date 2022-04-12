// SPDX-License-Identifier: MIT
// Copyright (c) 2022 The Pybricks Authors

// Common functions used by virtual (Python) drivers.

#ifndef _INTERNAL_PBDRV_VIRTUAL_H_
#define _INTERNAL_PBDRV_VIRTUAL_H_

#include <stdbool.h>

#include <pbio/error.h>

typedef struct _object PyObject;

/**
 * User-defined callback to handle exceptions from CPython.
 * @param [in]  type Borrowed ref to the exception type.
 * @param [in]  value Borrowed ref to the exception value.
 * @param [in]  traceback Borrowed ref to the exception stack trace.
 * @returns     true if the exception was "handled" and the unhanded exception
 *              message should be supressed or false to print an unhandled
 *              exception message.
 */
typedef bool (*pbdrv_virtual_cpython_exception_handler_t)(PyObject *type, PyObject *value, PyObject *traceback);

// REVISIT: these are high-level APIs and might need to be moved to a different header file
pbio_error_t pbdrv_virtual_platform_start(pbdrv_virtual_cpython_exception_handler_t handler);
pbio_error_t pbdrv_virtual_platform_stop(void);
pbio_error_t pbdrv_virtual_poll_events(void);

pbio_error_t pbdrv_virtual_platform_call_method(const char *name, const char *fmt, ...);
unsigned long pbdrv_virtual_get_signed_long(const char *property);
unsigned long pbdrv_virtual_get_indexed_signed_long(const char *property, uint8_t index);
unsigned long pbdrv_virtual_get_unsigned_long(const char *property);
unsigned long pbdrv_virtual_get_indexed_unsigned_long(const char *property, uint8_t index);
pbio_error_t pbdrv_virtual_get_u8(const char *component, int index,  const char *attribute, uint8_t *value);
pbio_error_t pbdrv_virtual_get_u16(const char *component, int index, const char *attribute, uint16_t *value);
pbio_error_t pbdrv_virtual_get_u32(const char *component, int index, const char *attribute, uint32_t *value);

#endif // _INTERNAL_PBDRV_VIRTUAL_H_
