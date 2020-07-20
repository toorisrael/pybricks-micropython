// SPDX-License-Identifier: MIT
// Copyright (c) 2018-2020 The Pybricks Authors

#include <pbdrv/config.h>

#if PBDRV_CONFIG_LIGHT

#include <pbdrv/light.h>
#include <pbdrv/pwm.h>
#include <pbio/config.h>
#include <pbio/error.h>
#include <pbio/port.h>

pbio_error_t pbdrv_light_set_rgb(pbio_port_t port, const pbdrv_light_raw_rgb_t *raw) {
    if (port != PBIO_PORT_SELF) {
        return PBIO_ERROR_INVALID_PORT;
    }

    pbdrv_pwm_dev_t *dev;
    if (pbdrv_pwm_get_dev(2, &dev) == PBIO_SUCCESS) {
        pbdrv_pwm_set_duty(dev, 1, raw->r);
    }
    if (pbdrv_pwm_get_dev(0, &dev) == PBIO_SUCCESS) {
        pbdrv_pwm_set_duty(dev, 3, raw->g);
    }
    if (pbdrv_pwm_get_dev(1, &dev) == PBIO_SUCCESS) {
        pbdrv_pwm_set_duty(dev, 2, raw->b);
    }

    return PBIO_SUCCESS;
}

pbio_error_t pbdrv_light_get_rgb_for_color(pbio_port_t port, pbio_light_color_t color,
    pbdrv_light_raw_rgb_t *raw) {
    if (port != PBIO_PORT_SELF) {
        return PBIO_ERROR_INVALID_PORT;
    }

    switch (color) {
        case PBIO_LIGHT_COLOR_WHITE:
            raw->r = 255;
            raw->g = 140;
            raw->b = 60;
            break;
        case PBIO_LIGHT_COLOR_RED:
            raw->r = 255;
            raw->g = 0;
            raw->b = 0;
            break;
        case PBIO_LIGHT_COLOR_ORANGE:
            raw->r = 255;
            raw->g = 25;
            raw->b = 0;
            break;
        case PBIO_LIGHT_COLOR_YELLOW:
            raw->r = 255;
            raw->g = 70;
            raw->b = 0;
            break;
        case PBIO_LIGHT_COLOR_GREEN:
            raw->r = 0;
            raw->g = 200;
            raw->b = 0;
            break;
        case PBIO_LIGHT_COLOR_BLUE:
            raw->r = 0;
            raw->g = 0;
            raw->b = 255;
            break;
        case PBIO_LIGHT_COLOR_PURPLE:
            raw->r = 220;
            raw->g = 0;
            raw->b = 120;
            break;
        default:
            raw->r = 0;
            raw->g = 0;
            raw->b = 0;
            break;
    }

    return PBIO_SUCCESS;
}

#endif // PBDRV_CONFIG_LIGHT
