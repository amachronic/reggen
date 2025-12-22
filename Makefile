##
## Configuration
##

CC     := gcc
CFLAGS := -Wall -Wextra

ifeq ($(DEBUG),1)
  CFLAGS += -Og -ggdb
else
  CFLAGS += -O2
endif

ifeq ($(ASAN),1)
  CFLAGS += -fsanitize=address
endif

##
## Build logic
##

SRC := \
	src/array.c \
	src/common.c \
	src/generate.c \
	src/hashmap.c \
	src/main.c \
	src/output.c \
	src/parse.c \
	src/validate.c

OBJ := $(SRC:.c=.o)
DEP := $(OBJ:.o=.d)

BIN := reggen
REGGEN := ./reggen

empty :=
tab   := $(empty)	$(empty)

ifeq ($(V),1)
  buildlog =
  silent :=
else
  buildlog = @$(call info,$(1)$(tab)$(2))
  silent := @
endif

all: $(BIN)

example: example-stm32h743 example-x1000 example-cm7

example-stm32h743: regs/stm32h743.regs $(BIN)
	@mkdir -p out/stm32h743
	$(REGGEN) regs/stm32h743.regs -o out/stm32h743

example-x1000: regs/x1000.regs $(BIN)
	@mkdir -p out/x1000
	$(REGGEN) $< -o out/x1000

example-cm7: regs/cortex-m7.regs $(BIN)
	@mkdir -p out/cm7
	$(REGGEN) $< -o out/cm7

clean:
	rm -f $(BIN) $(OBJ) $(DEP)
	rm -rf out/

.PHONY: all example example-stm32h743 example-x1000 example-cm7 clean

$(BIN): $(OBJ)
	$(call buildlog,LINK,$@)$(CC) $(CFLAGS) -o $@ $^

%.o: %.c
	@mkdir -p $(@D)
	$(call buildlog,CC,$<)$(CC) -MT $@ -MD -MP -MF $(O)$*.d $(CFLAGS) -c $< -o $@

$(DEP):
	@mkdir -p $(@D)

-include $(DEP)
