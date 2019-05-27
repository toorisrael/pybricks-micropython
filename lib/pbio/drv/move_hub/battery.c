// SPDX-License-Identifier: MIT
// Copyright (c) 2018-2019 David Lechner

#include <pbdrv/config.h>

#if PBDRV_CONFIG_BATTERY

#include <pbdrv/adc.h>

#include <pbio/error.h>
#include <pbio/port.h>
#include <sys/process.h>

PROCESS(pbdrv_battery_process, "battery");

#define PBDRV_BATTERY_VOLTAGE_CH 11
#define PBDRV_BATTERY_CURRENT_CH 10

pbio_error_t pbdrv_battery_get_voltage_now(pbio_port_t port, uint16_t *value) {
    uint16_t raw;
    pbio_error_t err;

    if (port != PBIO_PORT_SELF) {
        return PBIO_ERROR_INVALID_PORT;
    }

    err = pbdrv_adc_get_ch(PBDRV_BATTERY_VOLTAGE_CH, &raw);
    if (err != PBIO_SUCCESS) {
        return err;
    }

    // REVISIT: do we want to take into account shunt resistor voltage drop
    // like on EV3? Probably only makes a difference of ~10mV at the most.
    *value = raw * 9600 / 3893;

    return PBIO_SUCCESS;
}

pbio_error_t pbdrv_battery_get_current_now(pbio_port_t port, uint16_t *value) {
    uint16_t raw;
    pbio_error_t err;

    if (port != PBIO_PORT_SELF) {
        return PBIO_ERROR_INVALID_PORT;
    }

    // this is measuring the voltage across a 0.05 ohm shunt resistor probably
    // via an op amp with unknown gain.
    err = pbdrv_adc_get_ch(PBDRV_BATTERY_CURRENT_CH, &raw);
    if (err != PBIO_SUCCESS) {
        return err;
    }

    // FIXME: these values come from LEGO firmware, but seem to be 2x current
    *value = raw * 2444 / 4095;

    return PBIO_SUCCESS;
}

PROCESS_THREAD(pbdrv_battery_process, ev, data) {
    PROCESS_BEGIN();

    while (true) {
        PROCESS_WAIT_EVENT();
    }

    PROCESS_END();
}

#endif // PBDRV_CONFIG_BATTERY
