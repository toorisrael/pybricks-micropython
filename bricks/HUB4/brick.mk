# SPDX-License-Identifier: MIT
# Copyright (c) 2013, 2014 Damien P. George

include ../../../../py/mkenv.mk

# qstr definitions (must come before including py.mk)
QSTR_GLOBAL_DEPENDENCIES = mpconfigbrick.h

#PYBRICKS_MPY_MAIN_MODULE ?= modules/main.py

# directory containing scripts to be frozen as bytecode
FROZEN_MPY_DIR ?= modules
FROZEN_MPY_TOOL_ARGS = -mlongint-impl=none

# include py core make definitions
include $(TOP)/py/py.mk

CROSS_COMPILE ?= arm-none-eabi-

INC += -I.
INC += -I$(TOP)
INC += -I$(TOP)/lib/cmsis/inc
INC += -I$(TOP)/lib/stm32lib/CMSIS/STM32F0xx/Include
INC += -I$(TOP)/ports/pybricks/lib/pbio/drv/hub4
INC += -I$(TOP)/ports/pybricks/lib/pbio/include
INC += -I$(TOP)/ports/pybricks/lib/pbio/platform/hub4
INC += -I$(TOP)/ports/pybricks/lib/pbio
INC += -I$(TOP)/ports/pybricks/lib/BlueNRG-MS/includes
INC += -I$(TOP)/ports/pybricks/extmod
INC += -I$(BUILD)

DFU = $(TOP)/tools/dfu.py
PYDFU = $(TOP)/tools/pydfu.py
CHECKSUM = $(TOP)/ports/pybricks/tools/checksum.py
FIRMWARE_MAX_SIZE = 237568

PBIO_OPT = -DPBIO_CONFIG_ENABLE_SYS
PBIO_OPT += -DPBIO_CONFIG_ENABLE_MOTORS

CFLAGS_CORTEX_M0 = -mthumb -mtune=cortex-m0 -mcpu=cortex-m0  -msoft-float
CFLAGS = $(INC) -Wall -Werror -std=c99 -nostdlib $(CFLAGS_CORTEX_M0) $(COPT) $(PBIO_OPT)
LDFLAGS = -nostdlib -T hub4.ld -Map=$@.map --cref --gc-sections

# Tune for Debugging or Optimization
ifeq ($(DEBUG), 1)
CFLAGS += -O0 -ggdb
else
CFLAGS += -Os -DNDEBUG
CFLAGS += -fdata-sections -ffunction-sections
endif

ifneq ($(PYBRICKS_MPY_MAIN_MODULE),)
CFLAGS += -DPYBRICKS_MPY_MAIN_MODULE=MP_STRINGIFY\($(basename $(notdir $(PYBRICKS_MPY_MAIN_MODULE)))\)
endif

ifneq ($(FROZEN_MPY_DIR),)
# To use frozen bytecode, put your .py files in a subdirectory (eg frozen/) and
# then invoke make with FROZEN_MPY_DIR=frozen (be sure to build from scratch).
CFLAGS += -DMICROPY_QSTR_EXTRA_POOL=mp_qstr_frozen_const_pool
CFLAGS += -DMICROPY_MODULE_FROZEN_MPY
endif

LIBS = $(shell $(CC) $(CFLAGS) -print-libgcc-file-name)

SRC_C = \
	main.c \
	modhub4.c \
	accel.c \
	systick.c \
	uart_core.c \
	lib/utils/interrupt_char.c \
	lib/utils/printf.c \
	lib/utils/stdout_helpers.c \
	lib/utils/pyexec.c \
	lib/libc/string0.c \
	lib/mp-readline/readline.c \

SRC_S = \
	ports/pybricks/lib/pbio/platform/hub4/startup_stm32f030xc.s \
	ports/stm32/gchelper_m0.s \

# Pybricks modules
PYBRICKS_DRIVERS_SRC_C = $(addprefix ports/pybricks/,\
	extmod/pberror.c \
	extmod/modpupdevices.c \
	extmod/modparameters.c \
	extmod/modiodevice.c \
	extmod/modadvanced.c \
	extmod/modhubcommon.c \
	extmod/modcommon.c \
	extmod/modbattery.c \
	extmod/modmotor.c \
	extmod/modtools.c \
	)

BLUENRG_SRC_C = $(addprefix ports/pybricks/lib/BlueNRG-MS/hci/,\
	controller/bluenrg_gap_aci.c \
	controller/bluenrg_gatt_aci.c \
	controller/bluenrg_hal_aci.c \
	controller/bluenrg_l2cap_aci.c \
	controller/bluenrg_updater_aci.c \
	hci_le.c \
	)

PBIO_SRC_C = $(addprefix ports/pybricks/lib/pbio/,\
	drv/hub4/adc.c \
	drv/hub4/battery.c \
	drv/hub4/bluetooth.c \
	drv/hub4/button.c \
	drv/hub4/light.c \
	drv/hub4/ioport.c \
	drv/hub4/motor.c \
	drv/hub4/uart.c \
	platform/hub4/clock.c \
	platform/hub4/sys.c \
	src/motor.c \
	src/error.c \
	src/iodev.c \
	src/motorcontrol.c \
	src/motorref.c \
	src/light.c \
	src/main.c \
	src/uartdev.c \
	sys/autostart.c \
	sys/etimer.c \
	sys/process.c \
	sys/timer.c \
	)

SRC_LIBM = $(addprefix lib/libm/,\
	math.c \
	acoshf.c \
	asinfacosf.c \
	asinhf.c \
	atan2f.c \
	atanf.c \
	atanhf.c \
	ef_rem_pio2.c \
	erf_lgamma.c \
	fmodf.c \
	kf_cos.c \
	kf_rem_pio2.c \
	kf_sin.c \
	kf_tan.c \
	log1pf.c \
	nearbyintf.c \
	sf_cos.c \
	sf_erf.c \
	sf_frexp.c \
	sf_ldexp.c \
	sf_modf.c \
	sf_sin.c \
	sf_tan.c \
	wf_lgamma.c \
	wf_tgamma.c \
	ef_sqrt.c \
	)

OBJ = $(PY_O) $(addprefix $(BUILD)/, $(SRC_C:.c=.o) $(SRC_S:.s=.o))
OBJ += $(addprefix $(BUILD)/, $(PYBRICKS_DRIVERS_SRC_C:.c=.o))
OBJ += $(addprefix $(BUILD)/, $(BLUENRG_SRC_C:.c=.o))
OBJ += $(addprefix $(BUILD)/, $(PBIO_SRC_C:.c=.o))
OBJ += $(addprefix $(BUILD)/, $(SRC_LIBM:.c=.o))

# Optionally append .mpy file specified by PYBRICKS_MPY_MAIN_MODULE to 2K free space after 106K firmware
ifneq ($(PYBRICKS_MPY_MAIN_MODULE),)
OBJ += $(BUILD)/main_mpy.o

$(BUILD)/main.mpy: $(PYBRICKS_MPY_MAIN_MODULE)
	$(Q)$(MPY_CROSS) -o $@ $(MPY_CROSS_FLAGS) $^

$(BUILD)/main_mpy.o: $(BUILD)/main.mpy
	$(Q)$(OBJCOPY) -I binary -O elf32-littlearm -B arm --rename-section .data=.mpy,alloc,load,readonly,data,contents $^ $@

FIRMWARE_EXTRA_ARGS = -j .user --gap-fill=0xff
endif

# List of sources for qstr extraction
SRC_QSTR += $(SRC_C) $(PYBRICKS_DRIVERS_SRC_C)
# Append any auto-generated sources that are needed by sources listed in SRC_QSTR
SRC_QSTR_AUTO_DEPS +=

all: $(BUILD)/firmware.bin

$(BUILD)/firmware-no-checksum.elf: $(OBJ)
	$(Q)$(LD) --defsym=CHECKSUM=0 $(LDFLAGS) -o $@ $^ $(LIBS)

$(BUILD)/firmware-no-checksum.bin: $(BUILD)/firmware-no-checksum.elf
	$(Q)$(OBJCOPY) -O binary -j .isr_vector -j .text -j .data $^ $@

$(BUILD)/firmware.elf: $(BUILD)/firmware-no-checksum.bin $(OBJ)
	$(ECHO) "LINK $@"
	$(Q)$(LD) --defsym=CHECKSUM=`$(CHECKSUM) $< $(FIRMWARE_MAX_SIZE)` $(LDFLAGS) -o $@ $(filter-out $<,$^) $(LIBS)
	$(Q)$(SIZE) $@

$(BUILD)/firmware.bin: $(BUILD)/firmware.elf
	$(ECHO) "BIN creating firmware file"
	$(Q)$(OBJCOPY) -O binary -j .isr_vector -j .text -j .data $(FIRMWARE_EXTRA_ARGS) $^ $@
	$(ECHO) "`wc -c < $@` bytes"


include $(TOP)/py/mkrules.mk
