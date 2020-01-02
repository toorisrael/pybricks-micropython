// SPDX-License-Identifier: MIT
// Copyright (c) 2018-2019 Laurens Valk

#include <pbio/light.h>
#include <pbio/error.h>

#include "py/mpconfig.h"

#include <stdio.h>

#include "pblight.h"

pbio_error_t pb_light_on(pbdevice_t *pbdev) {
    // Turn the light on, using the command specific to the device.
    return PBIO_ERROR_NOT_SUPPORTED;
}

pbio_error_t pb_color_light_on(pbdevice_t *pbdev, pbio_light_color_t color) {
    if (!pbdev) {
        // No external device, so assume command is for the internal light
        return pbio_light_on(PBIO_PORT_SELF, color);
    }

#if PYBRICKS_PY_EV3DEVICES
    if (pbdevice_get_id(pbdev) == PBIO_IODEV_TYPE_ID_NXT_COLOR_SENSOR) {
        return pbdevice_get_values(pbdev, PBIO_IODEV_MODE_NXT_COLOR_SENSOR__LAMP, &color);
    }
#endif
#if PYBRICKS_PY_PUPDEVICES
    if (pbdevice_get_id(pbdev) == PBIO_IODEV_TYPE_ID_COLOR_DIST_SENSOR) {
        uint8_t mode;
        switch (color) {
            case PBIO_LIGHT_COLOR_GREEN:
                mode = 1;
                break;
            case PBIO_LIGHT_COLOR_RED:
                mode = 3;
                break;
            case PBIO_LIGHT_COLOR_BLUE:
                mode = 4;
                break;
            default:
                mode = 7;
                break;
        }
        pb_iodevice_set_mode(pbdev, mode);
        uint8_t *data;
        return pbio_iodev_get_data(pbdev, &data);
    }
#endif
    return PBIO_SUCCESS;
}
